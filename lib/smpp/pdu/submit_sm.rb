# Sending an MT message
class Smpp::Pdu::SubmitSm < Smpp::Pdu::Base
  handles_cmd SUBMIT_SM
  attr_reader :service_type, :source_addr_ton, :source_addr_npi, :source_addr, :dest_addr_ton, :dest_addr_npi, 
              :destination_addr, :esm_class, :protocol_id, :priority_flag, :schedule_delivery_time, 
              :validity_period, :registered_delivery, :replace_if_present_flag, :data_coding, 
              :sm_default_msg_id, :sm_length, :udh, :short_message, :optional_parameters

  def initialize(source_addr, destination_addr, short_message, options={}, seq = nil)

    if short_message.non_ascii?
        short_message = Iconv.conv("UCS-2be", "UTF-8", short_message)
        options[:data_coding] = 8
    else
        # utf8 -> gsm
        #short_message = Iconv.conv("ISO-8859-1", "UTF-8", short_message)
        options[:data_coding] = 0
    end

    # utf8 -> gsm, 11 chars max
    #source_addr = Iconv.conv("US-ASCII", "UTF-8", source_addr)
    source_addr = source_addr.to_gsm7 #.slice(0..10)
    source_addr = source_addr.slice(0..10)

    @msg_body = short_message

    @udh                     = options[:udh]
    @service_type            = options[:service_type]? options[:service_type] :''
    @source_addr_ton         = options[:source_addr_ton]?options[:source_addr_ton]:0 # network specific
    @source_addr_npi         = options[:source_addr_npi]?options[:source_addr_npi]:1 # unknown
    @source_addr             = source_addr
    @dest_addr_ton           = options[:dest_addr_ton]?options[:dest_addr_ton]:1 # international
    @dest_addr_npi           = options[:dest_addr_npi]?options[:dest_addr_npi]:1 # unknown 
    @destination_addr        = destination_addr
    @esm_class               = options[:esm_class]?options[:esm_class]:0 # default smsc mode
    @protocol_id             = options[:protocol_id]?options[:protocol_id]:0
    @priority_flag           = options[:priority_flag]?options[:priority_flag]:0
    @schedule_delivery_time  = options[:schedule_delivery_time]?options[:schedule_delivery_time]:''
    @validity_period         = options[:validity_period]?options[:validity_period]:''
    @registered_delivery     = options[:registered_delivery]?options[:registered_delivery]:1 # we want delivery notifications
    @replace_if_present_flag = options[:replace_if_present_flag]?options[:replace_if_present_flag]:0
    @data_coding             = options[:data_coding]?options[:data_coding]:3 #latin-1
    @sm_default_msg_id       = options[:sm_default_msg_id]?options[:sm_default_msg_id]:0
    @short_message           = short_message
    payload                  = @udh ? @udh + @short_message : @short_message 
    @sm_length               = payload.length

    @optional_parameters     = options[:optional_parameters]

    # craft the string/byte buffer
    pdu_body = sprintf("%s\0%c%c%s\0%c%c%s\0%c%c%c%s\0%s\0%c%c%c%c%c%s", @service_type, @source_addr_ton, @source_addr_npi, @source_addr,
    @dest_addr_ton, @dest_addr_npi, @destination_addr, @esm_class, @protocol_id, @priority_flag, @schedule_delivery_time, @validity_period,
    @registered_delivery, @replace_if_present_flag, @data_coding, @sm_default_msg_id, @sm_length, payload)

    if @optional_parameters
      pdu_body << optional_parameters_to_buffer(@optional_parameters)
    end

    seq ||= next_sequence_number

    super(SUBMIT_SM, 0, seq, pdu_body)
  end
  
  # some special formatting is needed for SubmitSm PDUs to show the actual message content
  def to_human
    # convert header (4 bytes) to array of 4-byte ints
    a = @data.to_s.unpack('N4')       
    sprintf("(%22s) len=%3d cmd=%8s status=%1d seq=%03d (%s)", self.class.to_s[11..-1], a[0], a[1].to_s(16), a[2], a[3], @msg_body[0..30])
  end

  def self.from_wire_data(seq, status, body)
    options = {}

    options[:service_type], 
    options[:source_addr_ton], 
    options[:source_addr_npi], 
    source_addr, 
    options[:dest_addr_ton], 
    options[:dest_addr_npi], 
    destination_addr, 
    options[:esm_class], 
    options[:protocol_id],
    options[:priority_flag], 
    options[:schedule_delivery_time], 
    options[:validity_period], 
    options[:registered_delivery], 
    options[:replace_if_present_flag], 
    options[:data_coding], 
    options[:sm_default_msg_id],
    options[:sm_length], 
    remaining_bytes = body.unpack('Z*CCZ*CCZ*CCCZ*Z*CCCCCa*')

    short_message = remaining_bytes.slice!(0...options[:sm_length])

    #everything left in remaining_bytes is 3.4 optional parameters
    options[:optional_parameters] = optional_parameters(remaining_bytes)

    new(source_addr, destination_addr, short_message, options, seq) 
  end

end
