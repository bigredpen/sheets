require 'pusher'

class ExcelImportJob < ActiveJob::Base
  queue_as do
    (urgent_job?) ? :high_priority : :default
  end
  
  after_perform :notify_manager
  
  rescue_from(StandardError) do |exception|
    notify_failed_job_to_manager(exception)
  end
  
  attr_accessor :job
  
  
  def perform(filepath)
    @job = ExcelImporter.new(filepath).run
  end
  
  private
  
  def urgent_job?
    self.arguments.first =~ /\/urgent\//
  end
  
  def notify_manager
    Pusher.trigger('import_sheets_from_excel', 'after_perform', {
      type: "success",
      message: "Finished importing Excel spreadsheet"
    })
   end
   
   def notify_failed_job_to_manager(exception)
     @job.sheets.each {|sheet| sheet.destroy }
     #NotificationMailer.job_failed(User.find_manager, exception).deliver_later
   end
    
end