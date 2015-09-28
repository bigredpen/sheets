require 'RubyXL'
class ImportSheetsFromExcel < ActiveJob::Base
  queue_as :seed_job_listings
  
  def perform(x)
    sheets = []
    x.sheets.each_with_index do |xsheet,xno|
      sheet = Sheet.new(name: xsheet.name, no_logging: true)
      sheets << sheet

      xrows = x[xno].sheet_data.rows

      sheet.row_count     = xrows.size
      sheet.column_count  = xrows.map(&:cells).map(&:size).sort.last
      sheet.save

      xrows.map(&:cells).each_with_index do |xrow,row|
        xrow.each_with_index do |cell,col|
          val = cell.value rescue nil
          unless val.blank?
            cell = sheet[row][col]
            cell.content = val
            cell.save
          end
        end
      end
    end
    
  rescue Resque::TermException
      sleep(2)
      puts "ERROR - Job cleanup!!!!"
    end
    
end