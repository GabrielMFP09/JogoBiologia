using System;

namespace JogoBiologia.Progressao;

public enum SituacaoAquisicaoMutacao
{
    Adquirida,
    JaAdquirida,
    IncompativelComMutacaoExistente,
    PontosInsuficientes
}

public enum DisponibilidadeMutacao
{
    Disponivel,
    JaAdquirida,
    IncompativelComMutacaoExistente,
    PontosInsuficientes
}

public sealed class SistemaProgressaoMutacoes
{
    public DisponibilidadeMutacao ConsultarDisponibilidade(
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
            return DisponibilidadeMutacao.JaAdquirida;
        }

        foreach (DefinicaoMutacao mutacaoAtual in estadoTentativa.Mutacoes)
        {
            if (!EstaEmConflito(mutacao, mutacaoAtual))
            {
                continue;
            }

            identificadorMutacaoConflitante = mutacaoAtual.Identificador;
            return DisponibilidadeMutacao.IncompativelComMutacaoExistente;
        }

        if (estadoTentativa.PontosMutacao < mutacao.CustoPontosMutacao)
        {
            return DisponibilidadeMutacao.PontosInsuficientes;
        }

        return DisponibilidadeMutacao.Disponivel;
    }

    public SituacaoAquisicaoMutacao TentarAdquirir(
        EstadoTentativa estadoTentativa,
        DefinicaoMutacao mutacao,
        out string identificadorMutacaoConflitante)
    {
        DisponibilidadeMutacao disponibilidade = ConsultarDisponibilidade(
            estadoTentativa,
            mutacao,
            out identificadorMutacaoConflitante);

        if (disponibilidade != DisponibilidadeMutacao.Disponivel)
        {
            return disponibilidade switch
            {
                DisponibilidadeMutacao.JaAdquirida => SituacaoAquisicaoMutacao.JaAdquirida,
                DisponibilidadeMutacao.IncompativelComMutacaoExistente =>
                    SituacaoAquisicaoMutacao.IncompativelComMutacaoExistente,
                DisponibilidadeMutacao.PontosInsuficientes => SituacaoAquisicaoMutacao.PontosInsuficientes,
                _ => throw new InvalidOperationException("Disponibilidade de mutacao desconhecida.")
            };
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
