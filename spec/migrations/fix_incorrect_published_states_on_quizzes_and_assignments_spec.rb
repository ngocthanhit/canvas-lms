#
# Copyright (C) 2014 Instructure, Inc.
#
# This file is part of Canvas.
#
# Canvas is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, version 3 of the License.
#
# Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')
require 'db/migrate/20140616202420_fix_incorrect_published_states_for_quizzes_and_assignments.rb'

describe 'FixIncorrectPublishedStatesOnQuizzesAndAssignments' do
  it "should update the right assignments" do
    course(:active_all => true)
    a1 = @course.assignments.create!(:name => 'hi')
    a1.workflow_state.should == "published"

    a2 = @course.assignments.create!(:name => 'hi')
    Assignment.where(:id => a2.id).update_all(:workflow_state => "available")
    a2.reload.workflow_state.should == "available"

    a3 = @course.assignments.create!(:name => 'hi')
    Assignment.where(:id => a3.id).update_all(:workflow_state => "active")
    a3.reload.workflow_state.should == "active"

    a4 = @course.assignments.create!(:name => 'hi')
    a4.destroy
    a4.workflow_state.should == "deleted"

    FixIncorrectPublishedStatesForQuizzesAndAssignments.up

    a1.reload.workflow_state.should == "published"
    a2.reload.workflow_state.should == "published"
    a3.reload.workflow_state.should == "published"
    a4.reload.workflow_state.should == "deleted"
  end

  it "should update the right quizzes" do
    course(active_all: true)
    q1 = @course.quizzes.create! title: 'this'
    q1.workflow_state.should == 'created'

    q2 = @course.quizzes.create! title: 'that'
    q2.publish!
    q2.workflow_state.should == 'available'

    q3 = @course.quizzes.create! title: 'the_other'
    q3.publish!
    Quizzes::Quiz.where(id: q3).update_all(workflow_state: 'active')

    q4 = @course.quizzes.create!
    q4.destroy
    q4.workflow_state.should == 'deleted'

    FixIncorrectPublishedStatesForQuizzesAndAssignments.up

    q1.reload.workflow_state.should == 'created'
    q2.reload.workflow_state.should == 'available'
    q3.reload.workflow_state.should == 'available'
    q4.reload.workflow_state.should == 'deleted'
  end
end
