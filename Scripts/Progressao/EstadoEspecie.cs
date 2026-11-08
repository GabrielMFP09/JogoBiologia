using System;
using System.Collections.Generic;

namespace JogoBiologia.Progressao;

public sealed class EstadoEspecie
{
    private readonly HashSet<string> _identificadoresMutacoes = new(StringComparer.Ordinal);

    public IReadOnlyCollection<string> IdentificadoresMutacoes => _identificadoresMutacoes;

    internal bool PossuiMutacao(string identificadorMutacao)
    {
        return _identificadoresMutacoes.Contains(identificadorMutacao);
    }

    internal void AdicionarMutacao(string identificadorMutacao)
    {
        _identificadoresMutacoes.Add(identificadorMutacao);
    }
}
