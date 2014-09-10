require_relative '../recording_service'

describe Sunra::HLS::RecordingService do

  # String version of the results from the recording_service status page just
  # after service startup
  let(:service_started) do
    '{"studio_id":5,"project_id":null,"booking_id":null,"ffserver":true,"is_recording":false,"start_time":null,"end_time":null,"duration":"00:00:00","recorders":[{"format":"MP3","is_recording":false,"start":null,"end":null,"filename":null,"directory":"/mnt/RAID/VIDEO/NEWSessions","recording_number":0},{"format":"MP4","is_recording":false,"start":null,"end":null,"filename":null,"directory":"/mnt/RAID/VIDEO/NEWSessions","recording_number":0},{"format":"MPG","is_recording":false,"start":null,"end":null,"filename":null,"directory":"/mnt/RAID/VIDEO/NEWSessions","recording_number":0},{"format":"M3U8","is_recording":false,"start":null,"end":null,"filename":null,"directory":"/mnt/RAID/VIDEO/NEWSessions","recording_number":0}],"last_api_error":{"loc":"","msg":""}}'
  end

  # String version of the results from the recording_service status page while
  # a recording is in progress.
  let(:service_recording) do
    '{"studio_id":5,"project_id":"c704e899b838b7f98642af82a51a9c80b16fddbbc2da8579c87e9585ea153f8a19fded91","booking_id":52,"ffserver":true,"is_recording":true,"start_time":"2014-08-15T14:37:20+01:00","end_time":"2014-08-15T14:44:12+01:00","duration":"00:05:51","recorders":[{"format":"MP3","is_recording":true,"start":"2014-08-15T14:37:20+01:00","end":"null","filename":"2014-08-15-143720.MP3","directory":"/mnt/RAID/VIDEO/NEWSessions/c704e899b838b7f98642af82a51a9c80b16fddbbc2da8579c87e9585ea153f8a19fded91/52/","recording_number":1},{"format":"MP4","is_recording":true,"start":"2014-08-15T14:37:20+01:00","end":"null","filename":"2014-08-15-143720.MP4","directory":"/mnt/RAID/VIDEO/NEWSessions/c704e899b838b7f98642af82a51a9c80b16fddbbc2da8579c87e9585ea153f8a19fded91/52/","recording_number":1},{"format":"MPG","is_recording":true,"start":"2014-08-15T14:37:20+01:00","end":"null","filename":"2014-08-15-143720.MPG","directory":"/mnt/RAID/VIDEO/NEWSessions/c704e899b838b7f98642af82a51a9c80b16fddbbc2da8579c87e9585ea153f8a19fded91/52/","recording_number":1},{"format":"M3U8","is_recording":true,"start":"2014-08-15T14:37:20+01:00","end":"null","filename":"2014-08-15-143720.M3U8","directory":"/mnt/RAID/VIDEO/NEWSessions/c704e899b838b7f98642af82a51a9c80b16fddbbc2da8579c87e9585ea153f8a19fded91/52/hls","recording_number":1}],"last_api_error":{"loc":"recording_api.stop","msg":""}}'
  end

  # String version of the results from the recording_service status page while
  # a recording is in progress BUT without an M3U8 recorder.
  let(:service_recording_no_m3u8) do
    '{"studio_id":5,"project_id":"c704e899b838b7f98642af82a51a9c80b16fddbbc2da8579c87e9585ea153f8a19fded91","booking_id":52,"ffserver":true,"is_recording":true,"start_time":"2014-08-15T14:37:20+01:00","end_time":"2014-08-15T14:44:12+01:00","duration":"00:05:51","recorders":[{"format":"MP3","is_recording":false,"start":"2014-08-15T14:37:20+01:00","end":"null","filename":"2014-08-15-143720.MP3","directory":"/mnt/RAID/VIDEO/NEWSessions/c704e899b838b7f98642af82a51a9c80b16fddbbc2da8579c87e9585ea153f8a19fded91/52/","recording_number":1},{"format":"MP4","is_recording":false,"start":"2014-08-15T14:37:20+01:00","end":"null","filename":"2014-08-15-143720.MP4","directory":"/mnt/RAID/VIDEO/NEWSessions/c704e899b838b7f98642af82a51a9c80b16fddbbc2da8579c87e9585ea153f8a19fded91/52/","recording_number":1},{"format":"MPG","is_recording":false,"start":"2014-08-15T14:37:20+01:00","end":"null","filename":"2014-08-15-143720.MPG","directory":"/mnt/RAID/VIDEO/NEWSessions/c704e899b838b7f98642af82a51a9c80b16fddbbc2da8579c87e9585ea153f8a19fded91/52/","recording_number":1}],"last_api_error":{"loc":"recording_api.stop","msg":""}}'
  end

  # String version of the results from the recording_service status page while
  # a recording is in progress.
  let(:service_post_recording) do
    '{"studio_id":5,"project_id":"c704e899b838b7f98642af82a51a9c80b16fddbbc2da8579c87e9585ea153f8a19fded91","booking_id":52,"ffserver":true,"is_recording":false,"start_time":"2014-08-15T14:37:20+01:00","end_time":"2014-08-15T14:44:12+01:00","duration":"00:06:52","recorders":[{"format":"MP3","is_recording":false,"start":"2014-08-15T14:37:20+01:00","end":"2014-08-15T14:44:08+01:00","filename":"2014-08-15-143720.MP3","directory":"/mnt/RAID/VIDEO/NEWSessions/c704e899b838b7f98642af82a51a9c80b16fddbbc2da8579c87e9585ea153f8a19fded91/52/","recording_number":1},{"format":"MP4","is_recording":false,"start":"2014-08-15T14:37:20+01:00","end":"2014-08-15T14:44:08+01:00","filename":"2014-08-15-143720.MP4","directory":"/mnt/RAID/VIDEO/NEWSessions/c704e899b838b7f98642af82a51a9c80b16fddbbc2da8579c87e9585ea153f8a19fded91/52/","recording_number":1},{"format":"MPG","is_recording":false,"start":"2014-08-15T14:37:20+01:00","end":"2014-08-15T14:44:09+01:00","filename":"2014-08-15-143720.MPG","directory":"/mnt/RAID/VIDEO/NEWSessions/c704e899b838b7f98642af82a51a9c80b16fddbbc2da8579c87e9585ea153f8a19fded91/52/","recording_number":1},{"format":"M3U8","is_recording":false,"start":"2014-08-15T14:37:20+01:00","end":"2014-08-15T14:44:10+01:00","filename":"2014-08-15-143720.M3U8","directory":"/mnt/RAID/VIDEO/NEWSessions/c704e899b838b7f98642af82a51a9c80b16fddbbc2da8579c87e9585ea153f8a19fded91/52/hls","recording_number":1}],"last_api_error":{"loc":"recording_api.stop","msg":""}}'
  end

  let(:expected_m3u8) do
    Pathname.new "/mnt/RAID/VIDEO/NEWSessions/c704e899b838b7f98642af82a51a9c80b16fddbbc2da8579c87e9585ea153f8a19fded91/52/hls/2014-08-15-143720.M3U8"
  end

  def rs_mock(service_status)
    rc = double('Sunra::Utils::RestClient')
    allow(rc).to receive(:get).and_return(service_status)

    Sunra::HLS::RecordingService.new(rc)
  end

  describe :is_recording? do
    context 'The service is recording' do
      let(:rs) { rs_mock(service_recording) }

      it 'returns true' do
        expect(rs.is_recording?).to eq true
      end
    end

    context 'The service is not recording' do
      let(:rs) { rs_mock(service_post_recording) }

      it 'returns false' do
        expect(rs.is_recording?).to eq false
      end
    end
  end

  describe :m3u8 do
    context 'when a m3u8 stream is being recorded' do
      let(:rs) { rs_mock(service_recording) }

      it 'returns the full path and filename of the m3u8 file' do
        expect(rs.m3u8).to eq expected_m3u8
      end
    end

    context 'when a m3u8 stream is not present' do
      let(:rs) { rs_mock(service_recording_no_m3u8) }

      it 'returns nil' do
        expect(rs.m3u8).to eq nil
      end
    end

    context 'when no recordings have been made' do
      let(:rs) { rs_mock(service_started) }

      it 'returns nil' do
        expect(rs.m3u8).to eq nil
      end
    end

    context 'after a recording has been stopped' do
      let(:rs) { rs_mock(service_post_recording) }

      it 'returns nil' do
        expect(rs.m3u8).to eq nil
      end

      context 'unless the ignore_recording_status parameter is set to true' do
        it 'returns nil' do
          expect(rs.m3u8(true)).to eq expected_m3u8
        end
      end
    end
  end
end
