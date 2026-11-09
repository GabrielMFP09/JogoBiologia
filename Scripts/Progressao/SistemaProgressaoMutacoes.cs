using System;

namespace JogoBiologia.Progressao;

public enum SituacaoAquisicaoMutacao
{
    Adquirida,
    JaAdquirida,
    IncompativelComMutacaoExistente,
    PontosInsuficientes
}

public sealed class SistemaProgressaoMutacoes
{
    public SituacaoAquisicaoMutacao TentarAdquirir(
        EstadoTentativa estadoTentativa,
        DefinicaoMutacao mutacao,
        out string identificadorMutacaoConflitante)
    {
        ArgumentNullException.ThrowIfNull(estadoTentativa);
        ArgumentNullException.ThrowIfNull(mutacao);

        if (string.IsNullOrWhiteSpace(mutacao.Identificador))
        {
            throw new ArgumentException("Uma mutacao precisa ter um identificador.", nameof(mutacao));
        }

        if (mutacao.CustoPontosMutacao < 0)
        {
            throw new ArgumentException("O custo de uma mutacao nao pode ser negativo.", nameof(mutacao));
        }

        identificadorMutacaoConflitante = string.Empty;

        if (estadoTentativa.PossuiMutacao(mutacao.Identificador))
        {
            return SituacaoAquisicaoMutacao.JaAdquirida;
        }

        foreach (DefinicaoMutacao mutacaoAtual in estadoTentativa.Mutacoes)
        {
            if (!EstaEmConflito(mutacao, mutacaoAtual))
            {
                continue;
            }

            identificadorMutacaoConflitante = mutacaoAtual.Identificador;
            return SituacaoAquisicaoMutacao.IncompativelComMutacaoExistente;
        }

        if (estadoTentativa.PontosMutacao < mutacao.CustoPontosMutacao)
        {
            return SituacaoAquisicaoMutacao.PontosInsuficientes;
        }

        estadoTentativa.GastarPontosMutacao(mutacao.CustoPontosMutacao);
        estadoTentativa.AdicionarMutacao(mutacao);
        return SituacaoAquisicaoMutacao.Adquirida;
    }

    private static bool EstaEmConflito(DefinicaoMutacao candidata, DefinicaoMutacao existente)
    {
        if (candidata.IdentificadoresMutacoesIncompativeis.Contains(existente.Identificador))
        {
            return true;
        }

        return existente.IdentificadoresMutacoesIncompativeis.Contains(candidata.Identificador);
    }
}
