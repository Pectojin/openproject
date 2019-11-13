#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2019 the OpenProject Foundation (OPF)
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

require 'spec_helper'

describe Bcf::API::V2_1::Projects::SingleRepresenter, 'rendering' do
  let(:project) { FactoryBot.build_stubbed(:project) }

  let(:instance) { described_class.new(project) }

  subject { instance.to_json }

  shared_examples_for 'attribute' do
    it 'reflects the project' do
      expect(subject)
        .to be_json_eql(value.to_json)
        .at_path(path)
    end
  end

  describe 'attributes' do
    context 'project_id' do
      it_behaves_like 'attribute' do
        let(:value) { project.id }
        let(:path) { 'project_id' }
      end
    end

    context 'name' do
      it_behaves_like 'attribute' do
        let(:value) { project.name }
        let(:path) { 'name' }
      end
    end
  end
end
