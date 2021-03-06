[![Code Climate](https://codeclimate.com/github/os6sense/sunra_hls_service/badges/gpa.svg)](https://codeclimate.com/github/os6sense/sunra_hls_service)

==== WORK IN PROGRESS. UNUSABLE ATM.

Used in conjunction with sunra_ffserver_relay and sunra_recording_service,
this service provides a simple mechanism for creating live HLS streams. All
that is needed on the web side is a webserver and ssh access.

The intent of the HLS service is that a live stream can be made available at
will. Access to the HLS stream will require providing a URL to the viewers 

BASIC OPERATION:

Check recording service status every n seconds

 - if it is recording and
 - if an M3U8 is being produced 
 - stop checking the recording service
 - start to monitor the M3U8 file

 - if the file is changed
   - check each file has been uploaded, if not add to the upload list
   - upload the changed M3U8 file.
   - check that the last line is not FINISH
      - if it is, stop monitoring

 - if the file hasn't changed for n seconds, check the recording service status
   (avoid waiting forever if recording service crashes for some reason)

 - start checking the recording service again

Design question - do I upload the M3U8 file after every addition, or do we have
                  a seperate service to which calls should be made with the new
                  filename details?
                  For now, I'll upload the file but the design should anticipate
                  this future change.

Design Notes: 
 - Where to upload to needs to be configurable.
 - Should I remove the HLS option from the media UI?
 - Do I already use the rest client to monitor the recording service?
 - SFTP uploader already exists in the lib from the uploader service.
 - Can I just run this in a background thread?
 - For file monitoring = https://github.com/nex3/rb-inotify

 - I really want this to be more modular and have additional functionality 
   outside of Sunra and as a generic way of creating HLS streams. 
      - monitor should be interchangable
      - would be useful if the recording_service could be configured to NOT
       require a booking or any of the "sunra" project management side of the
       service.
      - Multiple bitrates/resolution support should be added in the near future

