require 'net/http'
require 'cgi'

def typograf(params)
  STDOUT.sync = true
  input_text = STDIN.read

  post_args = <<SOAPBODY
<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    <soap:Body>
        <ProcessText xmlns="http://typograf.artlebedev.ru/webservices/">
            <text>#{CGI.escapeHTML(input_text)}</text>
            <entityType>#{params[:entity_type] || 0}</entityType>
            <useBr>#{params[:use_br] || 0}</useBr>
            <useP>#{params[:use_p] || 0}</useP>
            <maxNobr>3</maxNobr>
        </ProcessText>
    </soap:Body>
</soap:Envelope>
SOAPBODY

  Net::HTTP.start('typograf.artlebedev.ru') do |query|
    response = query.post('/webservices/typograf.asmx', post_args, {'Content-Type' => 'application/x-www-form-urlencoded'})
    response.body.scan(%r{<ProcessTextResult>(.*?)</ProcessTextResult>}m) do |result|
      return result.to_s
    end
  end
end
