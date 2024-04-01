class Stripe::WebhooksController < ApplicationController
  
  #need to let stripe make a post request to for our webhook
  skip_before_action :verify_authenticity_token

  def create 
    webhook_secret = 'whsec_830bd39c90f0547832a78c2e7532e0f5cc7518c32c4d106b3e9cda39965593b7'
    payload = request.body.read
    if !webhook_secret.empty?
      # Retrieve the event by verifying the signature using the raw body and secret if webhook signing is configured.
      sig_header = request.env['HTTP_STRIPE_SIGNATURE']
      event = nil

      begin
        event = Stripe::Webhook.construct_event(
          payload, sig_header, webhook_secret
        )
      rescue JSON::ParserError => e
        # Invalid payload
        status 400
        return
      rescue Stripe::SignatureVerificationError => e
        # Invalid signature
        puts '⚠️  Webhook signature verification failed.'
        status 400
        return
      end
    else
      data = JSON.parse(payload, symbolize_names: true)
      event = Stripe::Event.construct_from(data)
    end

    case event.type
    when 'customer.created'
      customer = event.data.object
      user = User.find_by(email: customer.email)
      user.update(stripe_customer_id: customer.id)
      
    when event.type == 'customer.subscription.deleted', event.type == 'customer.subscription.updated', event.type == 'customer.subscription.created'
      subscription = event.data.object
      user = User.find_by(stripe_customer_id: subscription.customer)
      user.update(
        plan: subscription.items.data[0].price.recurring.interval,
        subscription_status: subscription.status,
        subscription_ends_at: Time.at(subscription.current_period_end).to_datetime
      )
    end



    render json: { message: 'success' }
    end
end
