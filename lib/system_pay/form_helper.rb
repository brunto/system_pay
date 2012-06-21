module SystemPay::FormHelper

  def system_pay_hidden_fields(system_pay)

    res = "\n"
    system_pay.params.each{|key, value|
      res << hidden_field_tag(key[0].to_s, key[1].to_s) << "\n"
      res << hidden_field_tag(value[0].to_s, value[1].to_s) << "\n"
    }
    res

  end

end
