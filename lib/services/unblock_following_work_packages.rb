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

class Services::UnblockFollowingWorkPackages
  def initialize(journal)
    @journal = journal
    @work_package = WorkPackage.find(@journal.journable_id)
    @user = User.find(journal.user_id)
    @closed_status_ids = Status.where(is_closed: true).pluck(:id)
  end

  # Journal events can be triggered for many reasons, so we return early in many cases:
  # if status wasn't updated
  # if the current status is closed (e.g. changing from closed to rejected)
  # if the new status is not closed
  def run()
    return unless @journal.get_changes.has_key? "status_id"
    return if @journal.get_changes["status_id"].first.in? @closed_status_ids
    return unless @journal.get_changes["status_id"].last.in? @closed_status_ids
    # We want to consider both follow/precede and blocks/blocked-by relations
    dependents = (@work_package.precedes.with_status_open + WorkPackage.find(@work_package.block_ids)).uniq
    dependents.each do |dependent|
      unless dependent.follows.with_status_open.any?
        OpenProject::Notifications.send(OpenProject::Events::WORK_PACKAGE_UNBLOCKED,
                                        work_package: dependent,
                                        wp_unblocker: @user)
      end
    end
  end
end
