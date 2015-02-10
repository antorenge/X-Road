require 'json'
require 'common-ui/uploaded_file.rb'

java_import Java::ee.cyber.sdsb.common.SystemProperties

class ApplicationController < BaseController
  include MembersHelper

  FEDERATION_PRIVILEGES = [
    :view_external_configuration_source,
    :view_trusted_anchors,
    :upload_trusted_anchor,
    :delete_trusted_anchor,
    :download_trusted_anchor
  ]

  around_filter :wrap_in_transaction

  rescue_from ActiveRecord::StatementInvalid,
      ActiveRecord::ConnectionNotEstablished do
    ActiveRecord::Base.establish_connection
    error(t("common.db_error"))
    render_error_response($!.message)
  end

  before_filter :disable_federation
  before_filter :read_locale
  before_filter :check_conf, :except => [:menu]
  before_filter :read_server_id, :except => [:menu]
  before_filter :verify_get, :only => [
      :index,
      :get_records_count,
      :can_see_details]

  def member_classes
    render_json(MemberClass.get_all_codes)
  end

  # Number of total entries in the list
  def get_records_count
    raise "This must be overridden by explicit controller!"
  end

  def set_locale
    unless I18n.available_locales.include?(params[:locale].to_sym)
      raise "invalid locale"
    end

    ui_user = UiUser.find_by_username(current_user.name)

    unless ui_user
      ui_user = UiUser.new
      ui_user.username = current_user.name
    end

    ui_user.locale = params[:locale]
    ui_user.save!

    render :nothing => true
  end

  private

  def check_conf
    redirect_to :controller => :init unless initialized?
  end

  def initialized?
    SystemParameter.instance_identifier &&
      SystemParameter.central_server_address &&
      software_token_initialized?
  end

  def wrap_in_transaction
    ActiveRecord::Base.isolation_level(:repeatable_read) do
      ActiveRecord::Base.transaction do
        yield
      end
    end
  end

  def get_sort_column_no
    params[:iSortCol_0].to_i
  end

  def get_list_query_params(sort_column)
    ListQueryParams.new(
      sort_column,
      params[:sSortDir_0],
      params[:iDisplayStart],
      params[:iDisplayLength],
      params[:sSearch])
  end

  def get_advanced_search_params(request_param)
    return nil unless request_param

    raw_params = JSON.parse(request_param)

    return AdvancedSearchParams.new(
      {
        :name => raw_params["name"],
        :sdsb_instance => raw_params["sdsbInstance"],
        :member_class => raw_params["memberClass"],
        :member_code => raw_params["memberCode"],
        :subsystem_code => raw_params["subsystem"],
        :object_type => raw_params["objectType"],
        :service_code => raw_params["serviceCode"],
        :central_service_code => raw_params["centralServiceCode"],
        :server_code => raw_params["serverCode"]
      }
    )
  end

  def get_uploaded_file_param
    params.each do |each_key, each_value|
      logger.debug("Inspecting value for key '#{each_key}'")
      return each_value if each_value.is_a?(ActionDispatch::Http::UploadedFile)
    end
  end

  def render_details_visibility(privilege)
    render_json_without_messages({:can => can?(privilege)})
  end

  def render_cert_dump_and_hash(raw_cert)
    render_json({
      :cert_dump => CommonUi::CertUtils.cert_dump(raw_cert),
      :cert_hash => CommonUi::CertUtils.cert_hash(raw_cert)
    })
  end

  def disable_federation
    unless SystemProperties::getCenterTrustedAnchorsAllowed
      current_user.privileges -= FEDERATION_PRIVILEGES
    end
  end

  def read_locale
    return unless current_user

    ui_user = UiUser.find_by_username(current_user.name)
    I18n.locale = ui_user.locale if ui_user
  end

  def read_server_id
    return @server_id if @server_id

    @server_id = CentralServerId.new(SystemParameter.instance_identifier)
  end

  def validate_auth_cert(uploaded_file)
    CommonUi::UploadedFile::Validator.new(
        uploaded_file,
        AuthCertValidator.new).validate
  end

  class CentralServerId
    def initialize(sdsb_instance)
      @sdsb_instance = sdsb_instance
    end

    # To make it compatible with common-ui
    def toShortString
      return @sdsb_instance
    end
  end
end