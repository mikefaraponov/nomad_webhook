module NomadWebhook::Processor
  extend ActiveSupport::Concern

  included do
    before_action :check_nomad_event!, only: :create
  end

  NOMAD_EVENTS_WHITELIST = %w(
    terminated
    started
    killed
  )

  def create
    if self.respond_to?(event_method, true)
      @result = self.send event_method
      head :bad_request unless @result.success?
    else
      head :ok
    end
  end

  private

  def check_nomad_event!
    head :ok unless whitelisted?
  end

  def whitelisted?
    NOMAD_EVENTS_WHITELIST.include? nomad_task_event_type
  end

  def event_method
    @event_method ||= "nomad_#{nomad_task_event_type}".to_sym
  end

  def nomad_task_event_type
    params[:TaskEvent][:Type].split(' ').join('_').underscore
  end
end
