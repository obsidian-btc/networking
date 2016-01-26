class Connection
  module Controls
    module SSL
      module Context
        def self.example(cert: nil, key: nil, verify_mode: nil)
          verify_mode ||= OpenSSL::SSL::VERIFY_NONE

          ssl_context = OpenSSL::SSL::SSLContext.new
          ssl_context.set_params verify_mode: verify_mode
          ssl_context.cert = cert if cert
          ssl_context.key = key if key
          ssl_context
        end

        module Client
          def self.example
            Context.example
          end
        end

        module Server
          def self.example
            key = Key.example
            cert = Certificate::SelfSigned.example key
            Context.example cert: cert, key: key
          end
        end
      end

      module Key
        def self.example
          OpenSSL::PKey::RSA.new 2048
        end
      end

      module Certificate
        module SelfSigned
          def self.example(key=nil)
            key ||= Key.example

            name = OpenSSL::X509::Name.parse 'CN=nobody/DC=example'

            cert = OpenSSL::X509::Certificate.new
            cert.version = 2
            cert.serial = 0
            cert.not_before = Time.now
            cert.not_after = Time.now + 3600

            cert.public_key = key.public_key
            cert.subject = name
            cert.issuer = name
            cert.sign key, OpenSSL::Digest::SHA1.new

            cert
          end
        end
      end
    end
  end
end
