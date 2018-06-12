class BlastWorker
  include Sidekiq::Worker

  def perform(fasta)
    logs = []

    if fasta_valid?(fasta)
      status_log(logs.push({status: 'ok', message: 'valid fasta' }))

      blast_output = run_blast(fasta) # perform blast query

      if blast_output.empty?
        logs.push({status: 'ok', message: 'blast succeeded' })
        redirect = true
      else
        logs.push({status: 'fail', message: 'failed blast execution' })
      end
      status_log(logs, redirect)
    else
      status_log(logs.push({status: 'fail', message: 'invalid fasta' }))
    end # end if validation
  end # end perform

  def fasta_valid?(fasta)
    validator_binary = "fasta-validate.pl"

    validation_output = ''
    fasta_test = validator_binary + " " + fasta
    IO.popen( fasta_test ) do |io|
      while (line = io.gets) do
        validation_output += line
      end
    end
    true if validation_output == 'OK'
  end # end fasta_valid?

  def run_blast(fasta)
    # NOW BUILD AND DO THE BLAST
    blast_binary = "blastp"
    blast_db = "/usr/local/BLAST/aradu_prot.V14167.a1.M1"
    blast_output_file = "public/blasts/#{self.jid}.txt"
    blast_command = "#{blast_binary} -db #{blast_db} -query #{fasta} -out #{blast_output_file}"

    blast_errors = ''
    IO.popen( blast_command ) do |io|
      while (line = io.gets) do
        blast_errors += line
      end
    end

    blast_errors
  end # end perform_blast

  def status_log(messages, redirect = false)
    status_file = "public/status/#{self.jid}.html"
    redirect_js = 'window.location = "/blasts/' + self.jid + '.txt";' if redirect

    msg_str = ''
    messages.each do |msg|
      msg_str += "[<span class=\"status-#{msg[:status]}\">#{msg[:status]}</span>] .... #{msg[:message]}<br />\n"
    end

    f = File.new( status_file, "w")
    status_to_write = <<~END_STATUS_HTML
      <!DOCTYPE html>
      <html>
      <head>
      <script type="text/javascript">
      #{redirect_js}
      </script>
      <style>
        .status-ok { color: lightgreen; }
        .status-fail { color: red; }
      </style>
      </head>
      <body>
      #{msg_str}
      </body>
      </html>
    END_STATUS_HTML
    f.write(status_to_write)
    f.close
  end # end write_status_html
end # end class BlastWorker
