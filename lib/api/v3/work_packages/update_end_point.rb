module API
  module V3
    module WorkPackages
      class UpdateEndPoint < API::V3::Utilities::Endpoints::Update
        def present_success(current_user, call)
          work_package = WorkPackage.find(call.result['id'])
          Services::UnblockFollowingWorkPackages.new(work_package, current_user).run

          call.result.reload

          super
        end
      end
    end
  end
end
