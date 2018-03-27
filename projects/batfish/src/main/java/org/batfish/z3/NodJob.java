package org.batfish.z3;

import com.microsoft.z3.BitVecExpr;
import com.microsoft.z3.BoolExpr;
import com.microsoft.z3.Context;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.SortedSet;
import java.util.stream.Collectors;
import javax.annotation.Nonnull;
import org.batfish.common.Pair;
import org.batfish.config.Settings;
import org.batfish.z3.expr.QueryStatement;
import org.batfish.z3.expr.ReachabilityProgramOptimizer;
import org.batfish.z3.expr.RuleStatement;

public final class NodJob extends AbstractNodJob {

  private final SortedSet<Pair<String, String>> _nodeVrfSet;

  private Synthesizer _dataPlaneSynthesizer;

  private QuerySynthesizer _querySynthesizer;

  public NodJob(
      Settings settings,
      Synthesizer dataPlaneSynthesizer,
      QuerySynthesizer querySynthesizer,
      SortedSet<Pair<String, String>> nodeVrfSet,
      String tag) {
    super(settings, nodeVrfSet, tag);
    _dataPlaneSynthesizer = dataPlaneSynthesizer;
    _querySynthesizer = querySynthesizer;
    _nodeVrfSet = nodeVrfSet;
  }

  @Override
  protected SmtInput computeSmtInput(long startTime, Context ctx) {
    NodProgram program = getNodProgram(ctx);
    BoolExpr expr = computeSmtConstraintsViaNod(program, _querySynthesizer.getNegate());
    Map<String, BitVecExpr> variablesAsConsts = program.getNodContext().getVariablesAsConsts();
    return new SmtInput(expr, variablesAsConsts);
  }

  @Nonnull
  protected NodProgram getNodProgram(Context ctx) {
    ReachabilityProgram baseProgram =
        instrumentReachabilityProgram(_dataPlaneSynthesizer.synthesizeNodDataPlaneProgram());
    ReachabilityProgram queryProgram =
        instrumentReachabilityProgram(
            _querySynthesizer.getReachabilityProgram(_dataPlaneSynthesizer.getInput()));

    List<RuleStatement> allRules = new ArrayList<>(baseProgram.getRules());
    allRules.addAll(queryProgram.getRules());

    List<QueryStatement> allQueries = new ArrayList<>(baseProgram.getQueries());
    allQueries.addAll(queryProgram.getQueries());

    Set<RuleStatement> optimizedRules = ReachabilityProgramOptimizer.optimize(allRules, allQueries);

    ReachabilityProgram optimizedBaseProgram =
        ReachabilityProgram.builder()
            .setInput(baseProgram.getInput())
            .setRules(
                baseProgram
                    .getRules()
                    .stream()
                    .filter(optimizedRules::contains)
                    .collect(Collectors.toList()))
            .setQueries(baseProgram.getQueries())
            .build();

    ReachabilityProgram optimizedQueryProgram =
        ReachabilityProgram.builder()
            .setInput(queryProgram.getInput())
            .setRules(
                queryProgram
                    .getRules()
                    .stream()
                    .filter(optimizedRules::contains)
                    .collect(Collectors.toList()))
            .setQueries(queryProgram.getQueries())
            .build();

    return new NodProgram(ctx, optimizedBaseProgram, optimizedQueryProgram);
  }
}
