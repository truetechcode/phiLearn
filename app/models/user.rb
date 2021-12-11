class User < ApplicationRecord
  include Paginatable
  require 'csv'
  attr_accessor :login

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: {admin: 0, teacher: 1, student: 2 }

  belongs_to :school
  has_many :myCourses, class_name: 'Course', :dependent => :destroy, foreign_key: :owner_id
  has_many :solutions, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  has_many :students
  has_many :courses, through: :students
  has_one :info, class_name: 'Profile', :dependent => :destroy

  after_create :create_profile

  accepts_nested_attributes_for :school, allow_destroy: true

  def with_school
    build_school if school.nil?
    self
  end

  def self.import_from(file)
    users = []

    CSV.foreach(file.path, headers: true) do |row|
      users << User.new(row.to_h)
    end

    User.import! users

    users.each do |user|
      user.create_profile
    end
  end

  def create_profile
    info = Profile.new()
    info.public_src = 'public/profiles/' + self.username
    info.user_id = self.id
    info.save!
  end

end
