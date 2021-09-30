defmodule Video.Schema do
  @moduledoc """
  Macro with helper functionality for Ecto schemas.
  """

  defmacro __using__(_) do
    quote do
      alias Ecto.Changeset

      import Ecto.{Changeset, Query}

      use Ecto.Schema

      @type t :: %__MODULE__{}

      @before_compile unquote(__MODULE__)
    end
  end

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  defmacro __before_compile__(_opts) do
    schema = parse_module_schema(__CALLER__.module)

    query_keys =
      __CALLER__.module
      |> Module.get_attribute(:ecto_fields)
      |> Keyword.keys()
      |> Enum.map(&Atom.to_string/1)

    quote bind_quoted: [query_keys: query_keys, schema: schema],
          generated: true,
          location: :keep do
      defp base_query, do: from(__MODULE__, as: unquote(schema))

      @doc """
      Inits query.

      ## Examples

          iex> init_query()
          %Ecto.Query{}

      """
      @spec init_query() :: Ecto.Query.t()
      def init_query, do: base_query()

      @doc """
      Applies filter to query.

      ## Examples

          iex> filter(query, params)
          %Ecto.Query{}

      """
      @spec filter(Ecto.Query.t(), map()) :: Ecto.Query.t()
      def filter(query, params) do
        params
        |> Enum.map(fn {k, v} -> {maybe_to_string(k), v} end)
        |> Enum.reduce(query, &apply_filter/2)
      end

      defp apply_filter({key, nil}, query) when key in unquote(query_keys) do
        where(query, [{^unquote(schema), e}], field(e, ^is_nil(String.to_existing_atom(key))))
      end

      defp apply_filter({key, value}, query) when key in unquote(query_keys) and is_list(value) do
        where(query, [{^unquote(schema), e}], field(e, ^String.to_existing_atom(key)) in ^value)
      end

      defp apply_filter({key, value}, query) when key in unquote(query_keys) do
        where(query, [{^unquote(schema), e}], field(e, ^String.to_existing_atom(key)) == ^value)
      end

      defp apply_filter({_key, _value}, query), do: query

      defp maybe_to_string(value) when is_atom(value), do: Atom.to_string(value)
      defp maybe_to_string(value), do: value

      @doc """
      Applies sort to query.

      ## Examples

          iex> sort(query, key)
          %Ecto.Query{}

      """
      Enum.each(query_keys, fn key ->
        def sort(query, "#{unquote(key)}_asc") do
          order_by(query, [{^unquote(schema), e}],
            asc: field(e, ^String.to_existing_atom(unquote(key)))
          )
        end

        def sort(query, "#{unquote(key)}_desc") do
          order_by(query, [{^unquote(schema), e}],
            desc: field(e, ^String.to_existing_atom(unquote(key)))
          )
        end
      end)

      def sort(query, _) do
        order_by(query, [{^unquote(schema), e}], desc: e.updated_at)
      end
    end
  end

  defp parse_module_schema(mod) do
    mod
    |> to_string()
    |> String.split(".")
    |> List.last()
    |> Macro.underscore()
    |> String.to_atom()
  end
end
