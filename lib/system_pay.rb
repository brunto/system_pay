require 'active_support'
class SystemPay
  autoload :FormHelper, "system_pay/form_helper"

  @@target_url = "https://paiement.systempay.fr/vads-payment/"
  cattr_accessor :target_url

  @@vads_action_mode = 'INTERACTIVE'
  cattr_accessor :vads_action_mode

  @@vads_ctx_mode = 'TEST' # or 'PRODUCTION'
  cattr_accessor :vads_ctx_mode

  @@vads_contrib = 'Ruby'
  cattr_accessor :vads_contrib

  @@vads_page_action = 'PAYMENT'
  cattr_accessor :vads_page_action

  @@vads_payment_config = 'SINGLE'
  cattr_accessor :vads_payment_config

  @@vads_return_mode = 'GET'
  cattr_accessor :vads_return_mode

  @@vads_site_id = '123456' # change this value
  cattr_accessor :vads_site_id

  @@vads_validation_mode = '1'
  cattr_accessor :vads_validation_mode

  @@vads_version = 'V2'
  cattr_accessor :vads_version

  @@certificat = '1122334455667788'
  cattr_accessor :certificat

  attr_accessor :vads_amount, :vads_available_languages, :vads_capture_delay, :vads_contracts, :vads_currency, :vads_cust_address, :vads_cust_cell_phone,
  :vads_cust_email, :vads_redirect_error_message, :vads_redirect_success_message, :vads_trans_date, :vads_trans_id, :vads_url_cancel, :vads_url_error,
  :vads_url_referral, :vads_url_refused, :vads_url_success

  # Public: Creation of new instance.
  #
  # args - The hash of systempay parameters as describe in the implementation
  #        document. Note that each key should *not* contain the vads_ prefix.
  #        :amount - Should be in cents
  #        :trans_id - Will be automatically padded with zeros
  #
  # Examples
  #
  #   SystemPay.new(:amount => 100, :trans_id => 10, :url_return => 'http://mywebsite.com/return_url')
  #
  # Returns a new instance object
  def initialize args=nil
    args.each do |k,v|
      if k.to_s.match(/^vads_/)
        instance_variable_set("@#{k}", v) if !v.blank? && respond_to?(k)
      else
        instance_variable_set("@vads_#{k}", v) if !v.blank? && respond_to?("vads_#{k}")
      end
    end if args

    raise ArgumentError.new("You must specify a non blank :amount parameter") if @vads_amount.blank?
    raise ArgumentError.new("You must specify a non blank :trans_id parameter") if @vads_trans_id.blank?

    @vads_currency ||= '978' # Euros
    @vads_trans_date ||= Time.now.utc.strftime("%Y%m%d%H%M%S")
    @vads_trans_id = @vads_trans_id.to_s.rjust(6, '0')

  end

  # Public: Perform the signature of the request based on the parameters
  def signature
    sign(sorted_values)
  end

  # Public: Hash with parameters and value of the object
  def params
    Hash[*sorted_array + [['signature', signature]]]
  end

  # Public: Verify that the returned signature is valid.
  # Return boolean
  def valid_signature?(params)
    vads_params = params.sort.select{|value| value[0].to_s.match(/^vads_/)}.map{|value| value[1]}
    sign(vads_params) == params['signature']
  end


  private

  def sign(values)
    Digest::SHA1.hexdigest((values+[certificat]).join("+"))
  end

  def instance_variables_array
    instance_variables.map { |name| [name[1..-1], instance_variable_get(name)] }
  end

  def class_variables_array
    self.class.class_variables.select{|name| name.match(/^@@vads_/)}.map { |name| [name[2..-1], self.class.send(:class_variable_get, name)] }
  end

  def sorted_array
    (instance_variables_array + class_variables_array).uniq.sort
  end

  def sorted_values
    sorted_array.map{|value| value[1]}
  end

end
