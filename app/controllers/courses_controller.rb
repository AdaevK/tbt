class CoursesController < ApplicationController
  def index
    @courses_form = CoursesForm.new params.to_h
    @courses_form.get
  end
end
