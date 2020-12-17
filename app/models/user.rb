# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  # Validations
  # validates_presence_of :email, :password_digest
  validates :email,
            format: { with: URI::MailTo::EMAIL_REGEXP },
            presence: true,
            uniqueness: { case_sensitive: false }

  validates :username,
            format: {
              with: %r{\A[a-zA-ZÀ-ÖØ-öø-ÿ\w\s\'\"\./\-]+\z},
              message: 'Caractère non permis'
            },
            length: {
              minimum: 2
            },
            presence: true

  validates :password, :password_confirmation,
            format: {
              with: %r{\A[a-zA-ZÀ-ÖØ-öø-ÿ\w\s\'\"\./\-]+\z},
              message: 'Caractère non permis'
            },
            length: {
              minimum: 6
            },
            presence: true,
            if: :not_recovering_password

  def generate_password_token!
    self.reset_password_token = generate_token
    save!
  end

  # Token valids for 4hours
  def password_token_valid?
    (updated_at + 4.hours) > Time.now.utc
  end

  def reset_password!(password)
    self.reset_password_token = nil
    self.password = password
    save!
  end

  private

  def not_recovering_password
    reset_password_token.nil?
  end

  def generate_token
    SecureRandom.hex(10)
  end
end
