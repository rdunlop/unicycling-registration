desc "Update medical upload timestamps"
task update_medical_cert_upload_timestamps: :environment do
  Apartment.tenant_names.each do |tenant|
    Apartment::Tenant.switch(tenant) do
      puts "#{tenant} -> updating certificate timestamps"
      s3 = Aws::S3::Resource.new(region: "us-west-2")

      Registrant.all.find_each do |reg|
        next if reg.medical_certificate.blank?

        path = reg.medical_certificate.path
        object = s3.bucket(ENV["AWS_BUCKET"]).object(path)

        if object.present?
          reg.update!(medical_certificate_uploaded_at: object.last_modified.to_datetime)
          puts "updated medical certifate date for #{reg.bib_number}"
        else
          puts "unable to find s3 object for #{reg.bib_number}"
        end
      end
    end
  end
end
