module Twirp
  module Rails
    class Routing
      module Helper
        def use_twirp
          namespace :twirp do
            Twirp::Rails.services.each do |service|
              mount service, at: service.full_name
            end
          end
        end
      end
    end
  end
end

ActionDispatch::Routing::Mapper.include Twirp::Rails::Routing::Helper
