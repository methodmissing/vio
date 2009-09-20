$:.unshift "."
require File.dirname(__FILE__) + '/../ext/vio/vio'
require "benchmark"
require "logger"
require File.dirname(__FILE__) + '/patched_logger'

LOG_ENTRY_HEADER = %[Processing HotelsController#show (for 127.0.0.1 at 2009-03-18 19:29:38) [GET]
Parameters: {"action"=>"show", "id"=>"8699-radisson-hotel-waterfront-cape-town", "controller"=>"hotels"}]
LOG_ENTRY_BODY = %[Hotel Load Scrooged (0.3ms)   SELECT `hotels`.id FROM `hotels` WHERE (`hotels`.`id` = 8699) 
Rendering template within layouts/application
Rendering hotels/show
SQL (0.2ms)   SELECT `hotels`.location_id,`hotels`.hotel_name,`hotels`.location,`hotels`.from_price,`hotels`.star_rating,`hotels`.apt,`hotels`.latitude,`hotels`.longitude,`hotels`.distance,`hotels`.narrative,`hotels`.telephone,`hotels`.important_notes,`hotels`.nearest_tube,`hotels`.nearest_rail,`hotels`.created_at,`hotels`.updated_at,`hotels`.id FROM `hotels` WHERE `hotels`.id IN ('8699')
Image Load Scrooged (0.2ms)   SELECT `images`.id FROM `images` WHERE (`images`.hotel_id = 8699) LIMIT 1
SQL (0.2ms)   SELECT `images`.hotel_id,`images`.title,`images`.url,`images`.width,`images`.height,`images`.thumbnail_url,`images`.thumbnail_width,`images`.thumbnail_height,`images`.has_thumbnail,`images`.created_at,`images`.updated_at,`images`.id FROM `images` WHERE `images`.id IN ('488')
Rendered shared/_header (0.0ms)
Rendered shared/_navigation (0.2ms)
Image Load Scrooged (0.2ms)   SELECT `images`.id FROM `images` WHERE (`images`.hotel_id = 8699) 
SQL (0.2ms)   SELECT `images`.hotel_id,`images`.title,`images`.url,`images`.width,`images`.height,`images`.thumbnail_url,`images`.thumbnail_width,`images`.thumbnail_height,`images`.has_thumbnail,`images`.created_at,`images`.updated_at,`images`.id FROM `images` WHERE `images`.id IN ('488')
Address Columns (306.2ms)   SHOW FIELDS FROM `addresses`
Address Load Scrooged (3.6ms)   SELECT `addresses`.id FROM `addresses` WHERE (`addresses`.hotel_id = 8699) LIMIT 1
Rendered hotels/_show_sidebar (313.2ms)
Rendered shared/_footer (0.1ms)]
LOG_ENTRY_TRAILER = %[Completed in 320ms (View: 8, DB: 311) | 200 OK [http://localhost/hotels/8699-radisson-hotel-waterfront-cape-town]\n\n] 

FILE = File.dirname(__FILE__) + "/../test/fixtures/writable.txt"

logger = Logger.new(FILE)
logger.blank_slate

TESTS = 10_000
begin
  puts "* Bench log writes ..."
  Benchmark.bmbm do |results|
    results.report("IO.writev") { TESTS.times{ logger.addv(LOG_ENTRY_HEADER, LOG_ENTRY_BODY, LOG_ENTRY_TRAILER) } }  
    logger.blank_slate
    results.report("IO.write") { TESTS.times{ logger << "#{LOG_ENTRY_HEADER}\n#{LOG_ENTRY_BODY}\n#{LOG_ENTRY_TRAILER}" } }  
  end
ensure
  logger.blank_slate
  logger.close
end