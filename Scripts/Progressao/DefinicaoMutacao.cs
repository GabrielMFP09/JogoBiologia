using Godot;
using Godot.Collections;

namespace JogoBiologia.Progressao;

[GlobalClass]
public partial class DefinicaoMutacao : Resource
{
    // TODO: definir como os efeitos das mutacoes serao representados antes de associa-los a atributos ou ao combate.
    [Export]
    public string Identificador { get; set; } = string.Empty;

    [Export]
    public Array<string> IdentificadoresMutacoesIncompativeis { get; set; } = new();
}
