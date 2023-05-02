# typed: strict
# frozen_string_literal: true

module Packwerk
  # A command-line interface to Packwerk.
  class Cli
    extend T::Sig
    extend ActiveSupport::Autoload

    autoload :CommandRegistry
    autoload :BaseCommand
    autoload :CheckCommand
    autoload :HelpCommand
    autoload :InitCommand
    autoload :UpdateTodoCommand
    autoload :UsesParseRun
    autoload :ValidateCommand
    autoload :VersionCommand

    class << self
      extend T::Sig
      sig { params(name: String, help: String, aliases: T::Array[String]).void }
      def register_command(name, help:, aliases: [])
        CommandRegistry.register(name, help: help, aliases: aliases)
      end
    end

    sig do
      params(
        configuration: T.nilable(Configuration),
        out: T.any(StringIO, IO),
        err_out: T.any(StringIO, IO),
        environment: String,
        style: OutputStyle,
        offenses_formatter: T.nilable(OffensesFormatter)
      ).void
    end
    def initialize(
      configuration: nil,
      out: $stdout,
      err_out: $stderr,
      environment: "test",
      style: OutputStyles::Plain.new,
      offenses_formatter: nil
    )
      @out = out
      @err_out = err_out
      @environment = environment
      @style = style
      @configuration = T.let(configuration || Configuration.from_path, Configuration)
      @progress_formatter = T.let(Formatters::ProgressFormatter.new(@out, style: style), Formatters::ProgressFormatter)
      @offenses_formatter = T.let(
        offenses_formatter || @configuration.offenses_formatter,
        OffensesFormatter
      )
    end

    sig { params(args: T::Array[String]).returns(T.noreturn) }
    def run(args)
      success = execute_command(args)
      exit(success)
    end

    sig { params(args: T::Array[String]).returns(T::Boolean) }
    def execute_command(args)
      command = args.shift || "help"
      command_class = CommandRegistry.class_for(command)

      if command_class
        command_class.new(
          args,
          configuration: @configuration,
          out: @out,
          err_out: @err_out,
          progress_formatter: @progress_formatter,
          offenses_formatter: @offenses_formatter,
        ).run
      else
        @err_out.puts("'#{command}' is not a packwerk command. See `packwerk help`.",)

        false
      end
    end
  end

  Cli.register_command("init", help: "set up packwerk")
  Cli.register_command("check", help: "run all checks")
  Cli.register_command("update-todo", aliases: ["update"], help: "update package_todo.yml files")
  Cli.register_command("validate", help: "verify integrity of packwerk and package configuration")
  Cli.register_command("version", help: "output packwerk version")
  Cli.register_command("help", help: "display help information about packwerk")
end
