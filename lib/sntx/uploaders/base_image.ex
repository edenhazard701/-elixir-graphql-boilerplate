# Rails compatible macro
defmodule Sntx.Uploaders.BaseImage do
  defmacro __using__(opts) do
    quote do
      use Waffle.Definition
      use Waffle.Ecto.Definition

      @acl :public_read
      @extension_whitelist ~w(.jpg .jpeg .gif .png .bmp .webp)
      @default_max_size 4

      def max_size do
        settings = unquote(opts)
        (is_nil(settings[:max_size]) && @default_max_size) || settings[:max_size]
      end

      def filename(version, {file, _}) do
        version = (is_binary(version) && String.to_atom(version)) || version
        file_name = Path.basename(file.file_name, Path.extname(file.file_name))

        if version == :original do
          file_name
        else
          "#{version}_#{file_name}"
        end
      end

      def validate({file, _}) do
        case File.stat(file.path) do
          {:ok, %{size: size}} ->
            info = FileInfo.get_info(file.path)

            file_extension =
              file.file_name
              |> Path.extname()
              |> String.downcase()

            size < max_size() * 1024 * 1024 and
              !is_nil(info[file.path]) and
              info[file.path].type == "image" and
              Enum.member?(@extension_whitelist, file_extension)

          {:error, reason} ->
            false
        end
      end
    end
  end
end
