class User < ActiveRecord::Base
    has_many :events
    has_many :cals
end
