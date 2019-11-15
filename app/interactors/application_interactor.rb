# frozen_string_literal: true

class ApplicationInteractor
  include Interactor

  # It does not provide the "call" method for its subclasses, it can be overwritten.
  def call
    raise NotImplementedError
  end

  private

  def set_success_response(record)
    context.data = record
  end

  def not_found
    context.fail!(error: 'This resource does not exist')
  end

  def persist_record(resource_name, attributes)
    persisted_resource = retrieve_resource(resource_name, attributes[:spotify_id])
    if persisted_resource&.persisted?
      context.data = persisted_resource
    else
      new_record = resource_name.to_s.capitalize
                                .constantize.new(attributes)
      new_record.save ? set_success_response(new_record) : context.fail!(error: new_record.errors.to_s)
    end
  end

  def retrieve_resource(resource_name, spotify_id)
    resource_name.to_s.capitalize
                 .constantize.find_by(spotify_id: spotify_id)
  end


  # FIXME: Parse strings into symbols.
  def process_response(response)
    # NOTE: RSpotify does not provide serialized models for responses.
    # NOTE: It doesn't return HTTP status codes, so that is why we validate using Array#present.
    # ANCHOR: This method is provided my ActiveSupport, it parses strings into symbols.
    if response.present?
      if response.is_a?(Array)
        response.map(&:deep_symbolize_keys)
      else
        response.deep_symbolize_ke  ys
      end
    end
  end
end
