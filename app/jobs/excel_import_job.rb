class ExcelImportJob < ActiveJob::Base
  attr_accessor :job
    
  queue_as do
    (urgent_job?) ? :high_priority : :default
  end
  
  after_perform :notify_manager
  
  #rescue_from(StandardError) do |exception|
  #  notify_failed_job_to_manager(exception)
  #end

  
  def perform(filepath)
    job = ExcelImporter.new(filepath).run
  end
  
  private
  
  def urgent_job?
    self.arguments.first =~ /\/urgent\//
  end
  
  def notify_manager
    Pusher.trigger(self.class.name.underscore.to_sym, 'after_perform', {
      type: "success",
      message: "Finished importing Excel spreadsheet"
    })
   end
   
   def notify_failed_job_to_manager(exception)
     begin
       job.sheets.each {|sheet| sheet.destroy }
     rescue
       #NotificationMailer.job_failed(User.find_manager, exception).deliver_later
     end
   end
    
end