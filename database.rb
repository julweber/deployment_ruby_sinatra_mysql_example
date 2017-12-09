require 'logger'
require 'singleton'
require 'json'

class Database
  include ::Singleton

  attr_reader :database_service_name, :credentials

  def initialize
    @database_service_name = ENV['DATABASE_SERVICE_NAME']
    @credentials = load_service_by_environment_configuration
  end

  def load_service_by_environment_configuration
    logger.info "VCAP_SERVICES: #{ENV['VCAP_SERVICES']}"

    parsed_vcap_services = JSON.parse(ENV['VCAP_SERVICES'])
    logger.info "Parsed VCAP_SERVICES: #{parsed_vcap_services}"
    logger.info "Parsed VCAP_SERVICES class: #{parsed_vcap_services.class.to_s}"

    return {} if ENV['VCAP_SERVICES'].nil?
    parsed_vcap_services.each do |key, value|
      value = value.first
      if key == database_service_name
        return value['credentials']
      end
    end
    raise "service with name #{database_service_name} not found in bound services"
  end

  def client
    cl = Mysql2::Client.new(
      :host => credentials['hostname'],
      :username => credentials['username'],
      :port => credentials['port'].to_i,
      :password => credentials['password'],
      :database => credentials['name']
    )
    query = "SELECT table_name FROM information_schema.tables WHERE table_name = 'data_values'"
    log_query query
    result = cl.query query
    if result.count != 1
      logger.info "Table data_values not found! Creating table ..."
      query = "CREATE TABLE IF NOT EXISTS data_values ( id VARCHAR(20), data_value VARCHAR(20)); "
      log_query query
      cl.query query
    end
    cl
  end

  def get_key(key)
    cl = client
    query_string = "select data_value from data_values where id = '#{key}'"
    log_query query_string
    query = cl.query query_string
    value = query.first['data_value'] rescue nil
    cl.close
    value
  end

  def store_value(key, value)
    cl = client
    query_string = "select * from data_values where id = '#{key}'"
    log_query query_string
    result = cl.query query_string
    if result.count > 0
      query_string = "update data_values set data_value='#{value}' where id = '#{key}'"
      log_query query_string
      result = cl.query query_string
    else
      query_string = "insert into data_values (id, data_value) values('#{key}','#{value}');"
      log_query query_string
      cl.query query_string
    end
    cl.close
    result
  end

  def logger
    @logger = Logger.new(STDOUT) if @logger.nil?
    @logger
  end

  def log_query(query)
    logger.info "[Database][Query] : #{query}"
  end
end
