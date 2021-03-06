# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012-2013, Sebastian Staudt

class Revision

  include Mongoid::Document

  field :_id, type: String, default: ->{ sha }
  field :date, type: Time
  field :subject, type: String
  field :sha, type: String

  belongs_to :repository
  belongs_to :author

  has_and_belongs_to_many :added_formulae, class_name: 'Formula', inverse_of: nil
  has_and_belongs_to_many :updated_formulae, class_name: 'Formula', inverse_of: nil
  has_and_belongs_to_many :removed_formulae, class_name: 'Formula', inverse_of: nil

end
