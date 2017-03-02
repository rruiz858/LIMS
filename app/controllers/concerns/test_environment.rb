module TestEnvironment
  extend ActiveSupport::Concern
  private

  def test_environment
    Rails.env.test?
  end

  def update_progress_bar
   unless Rails.env.test?
     update_progress
   end
  end
end