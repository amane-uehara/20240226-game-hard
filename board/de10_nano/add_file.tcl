package require ::quartus::project
package require fileutil

foreach file [fileutil::findByPattern "../../src" *.sv] {
  puts $file
  set_global_assignment -name SYSTEMVERILOG_FILE $file
}

foreach file [fileutil::findByPattern "../../mem" *] {
  puts $file
  set_global_assignment -name MIF_FILE $file
}
