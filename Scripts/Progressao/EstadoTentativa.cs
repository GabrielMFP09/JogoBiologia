using System;
using System.Collections.Generic;

namespace JogoBiologia.Progressao;

public sealed class EstadoTentativa
{
    private readonly Dictionary<string, DefinicaoMutacao> _mutacoes = new(StringComparer.Ordinal);

    public int PontosMutacao { get; private set; }

    public IReadOnlyCollection<DefinicaoMutacao> Mutacoes => _mutacoes.Values;

    // TODO: definir quando os pontos de mutacao serao gastos; por enquanto, este estado registra apenas recompensas.
    public void ConcederPontosMutacao(int quantidade)
    {
        if (quantidade < 0)
        {
            throw new ArgumentOutOfRangeException(nameof(quantidade));
        }

        PontosMutacao = checked(PontosMutacao + quantidade);
    }

    internal bool PossuiMutacao(string identificadorMutacao)
    {
        return _mutacoes.ContainsKey(identificadorMutacao);
    }

    internal void AdicionarMutacao(DefinicaoMutacao mutacao)
    {
        _mutacoes.Add(mutacao.Identificador, mutacao);
    }
}
