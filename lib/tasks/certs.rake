namespace :certs do
  desc "Request ACM certificates for all tenant aliases that don't have a pending or issued cert"
  task request_all: :environment do
    aliases = TenantAlias.where(acm_cert_status: [nil, "failed"])
    puts "Enqueueing ACM certificate requests for #{aliases.count} domain(s)..."
    aliases.find_each do |ta|
      RequestAcmCertificateJob.perform_later(ta.id)
      puts "  Enqueued: #{ta.website_alias} (id=#{ta.id})"
    end
    puts "Done."
  end

  desc "Show ACM certificate status for all tenant aliases"
  task status: :environment do
    counts = TenantAlias.group(:acm_cert_status).count
    puts "ACM Certificate Status Summary:"
    puts "  nil (not requested): #{counts[nil] || 0}"
    puts "  pending:             #{counts['pending'] || 0}"
    puts "  issued:              #{counts['issued'] || 0}"
    puts "  failed:              #{counts['failed'] || 0}"
    puts ""
    puts "#{'Domain'.ljust(40)} #{'Status'.ljust(10)} Cert ARN"
    puts "-" * 100
    TenantAlias.order(:website_alias).each do |ta|
      puts "#{ta.website_alias.ljust(40)} #{(ta.acm_cert_status || 'none').ljust(10)} #{ta.acm_certificate_arn || '-'}"
    end
  end
end
