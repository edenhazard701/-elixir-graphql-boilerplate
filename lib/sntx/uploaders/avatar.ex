defmodule Sntx.Uploaders.Avatar do
  use Sntx.Uploaders.BaseImage

  @versions [:original, :small, :xsmall, :max]

  def transform(:small, _) do
    {:convert, "-strip -thumbnail 128x128^ -gravity center -extent 128x128"}
  end

  def transform(:xsmall, _) do
    {:convert, "-strip -thumbnail 64x64^ -gravity center -extent 64x64"}
  end

  def transform(:max, _) do
    {:convert, "-strip -thumbnail 256x256^ -gravity center -extent 256x256"}
  end

  # Override the storage directory:
  def storage_dir(_version, {_file, scope}) do
    "uploads/avatars/#{scope.id}"
  end
end
