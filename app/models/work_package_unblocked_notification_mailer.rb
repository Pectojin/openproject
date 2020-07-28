#-- encoding: UTF-8

#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2012-2020 the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2017 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See docs/COPYRIGHT.rdoc for more details.
#++

class WorkPackageUnblockedNotificationMailer
  class << self
    def handle_unblock(work_package, wp_unblocker)
      return unless notification_enabled?

      perform_notification_job(work_package, wp_unblocker)
    end

    private

    def perform_notification_job(work_package, wp_unblocker)
      users = User.find([
        work_package.assigned_to_id,
        work_package.responsible_id,
        work_package.watcher_ids
      ].flatten.uniq)
      users.each do |user|
        next unless notify_about_unblocked_wp?(work_package, user, wp_unblocker)
        DeliverWorkPackageUnblockedNotificationJob
          .perform_later(work_package.id, user.id, wp_unblocker.id)
        end
    end

    def notify_about_unblocked_wp?(work_package, user, wp_unblocker)
      return false if notify_about_self_watching?(user, wp_unblocker)
      user.notify_about?(work_package)
    end

    def notify_about_self_watching?(user, wp_unblocker)
      user == wp_unblocker && !user.pref.self_notified?
    end

    def notification_enabled?
      Setting.notified_events.include?("work_package_unblocked")
    end
  end
end
