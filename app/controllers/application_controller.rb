# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012-2013, Sebastian Staudt

class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from Mongoid::Errors::DocumentNotFound, with: :not_found

  def index
    @repository = Repository.main
    formulae = @repository.formulae.order_by [:date, :desc]

    @added, @updated, @removed = [], [], []
    formulae.each do |formula|
      if @added.size < 5 && formula.revision_ids.size == 1
        @added << formula
      elsif @updated.size < 5 && !formula.removed? &&
            formula.revision_ids.size > 1
        @updated << formula
      elsif @removed.size < 5 && formula.removed?
        @removed << formula
      end

      break if @added.size == 5 && @updated.size == 5 && @removed.size == 5
    end

    all_repos = Repository.all.order_by [:name, :asc]
    @alt_repos = {}
    (all_repos - [ @repository ]).each do |repo|
      ('a'..'z').select do |letter|
        if repo.formulae.letter(letter).where(removed: false).exists?
          @alt_repos[repo] = letter
          break
        end
      end
    end

    fresh_when last_modified: all_repos.max_by(&:updated_at).updated_at, public: true
  end

  def not_found
    flash.now[:error] = 'The page you requested does not exist.'
    index

    respond_to do |format|
      format.html { render 'application/index', status: :not_found }
    end

    headers.delete 'ETag'
    expires_in 5.minutes
  end

  def sitemap
    @repository = Repository.main

    respond_to do |format|
      format.xml
    end

    fresh_when etag: @repository.sha, public: true
  end

end
