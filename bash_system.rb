# Run a shell command under the bash shell
# instead of the default sh shell provided by
# system and ``

def bash_system(a_command_string)
  system "bash", "-c", a_command_string
end