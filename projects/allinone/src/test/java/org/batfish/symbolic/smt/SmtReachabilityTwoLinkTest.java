package org.batfish.symbolic.smt;

import static java.util.Collections.singleton;
import static org.batfish.symbolic.smt.matchers.SmtReachabilityAnswerElementMatchers.hasVerificationResult;
import static org.batfish.symbolic.smt.matchers.VerificationResultMatchers.hasFailures;
import static org.batfish.symbolic.smt.matchers.VerificationResultMatchers.hasIsVerified;
import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.allOf;
import static org.hamcrest.Matchers.instanceOf;

import java.io.IOException;
import java.util.SortedMap;
import org.batfish.datamodel.Configuration;
import org.batfish.datamodel.answers.AnswerElement;
import org.batfish.main.Batfish;
import org.batfish.question.SmtReachabilityQuestionPlugin.ReachabilityQuestion;
import org.batfish.symbolic.answers.SmtReachabilityAnswerElement;
import org.junit.Before;
import org.junit.Ignore;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TemporaryFolder;

public class SmtReachabilityTwoLinkTest {
  @Rule public TemporaryFolder _temp = new TemporaryFolder();

  private Batfish _batfish;
  private Configuration _dstNode;
  private Configuration _srcNode;
  private String _failureDesc;

  @Before
  public void setup() throws IOException {
    _batfish = TwoNodeNetworkWithTwoLinks.create(_temp);
    SortedMap<String, Configuration> configs = _batfish.loadConfigurations();
    _dstNode = configs.get(TwoNodeNetworkWithTwoLinks.DST_NODE);
    _srcNode = configs.get(TwoNodeNetworkWithTwoLinks.SRC_NODE);
    _failureDesc = String.format("link(%s,%s)", _dstNode.getName(), _srcNode.getName());
  }

  /**
   * Test that with one failure, both links between the two nodes are down, so no _dstIp is
   * reachable from the source.
   */
  @Test
  public void testOneFailure() {
    final ReachabilityQuestion question = new ReachabilityQuestion();
    question.setIngressNodeRegex(_srcNode.getName());
    question.setFinalNodeRegex(_dstNode.getName());
    question.setFailures(1);

    final AnswerElement answer = _batfish.smtReachability(question);
    assertThat(answer, instanceOf(SmtReachabilityAnswerElement.class));

    final SmtReachabilityAnswerElement smtAnswer = (SmtReachabilityAnswerElement) answer;
    assertThat(
        smtAnswer,
        hasVerificationResult(allOf(hasIsVerified(false), hasFailures(singleton(_failureDesc)))));
  }

  /**
   * Negation of the above test, i.e. verify unreachability under 1 failure.
   *
   * <p>{@link Ignore Ignored} because the test is failing. It's unclear whether the intent is that
   * failures constraint should be included in the negation. But that isn't working either
   * (otherwise, failures=0 should return a {@link VerificationResult} with failures != 0. It does
   * not).
   */
  @Ignore
  @Test
  public void testOneFailure_negate() {
    final ReachabilityQuestion question = new ReachabilityQuestion();
    question.setIngressNodeRegex(_srcNode.getName());
    question.setFinalNodeRegex(_dstNode.getName());
    question.setFailures(1);
    question.setNegate(true);

    final AnswerElement answer = _batfish.smtReachability(question);
    assertThat(answer, instanceOf(SmtReachabilityAnswerElement.class));

    final SmtReachabilityAnswerElement smtAnswer = (SmtReachabilityAnswerElement) answer;
    assertThat(
        smtAnswer,
        hasVerificationResult(allOf(hasIsVerified(true), hasFailures(singleton(_failureDesc)))));
  }

  @Test
  public void testOneFailure_notFailNode1() {
    final ReachabilityQuestion question = new ReachabilityQuestion();
    question.setIngressNodeRegex(_srcNode.getName());
    question.setFinalNodeRegex(_dstNode.getName());
    question.setFailures(1);

    // Dont allow edges connected to _srcNode to fail
    question.setNotFailNode1Regex(_srcNode.getName());
    question.setNotFailNode2Regex(".*");

    final AnswerElement answer = _batfish.smtReachability(question);
    assertThat(answer, instanceOf(SmtReachabilityAnswerElement.class));

    final SmtReachabilityAnswerElement smtAnswer = (SmtReachabilityAnswerElement) answer;
    assertThat(smtAnswer, hasVerificationResult(hasIsVerified(true)));
  }

  /** Test that the notFailNode*Regex parameters are not directional. */
  @Test
  public void testOneFailure_notFailNode2() {
    final ReachabilityQuestion question = new ReachabilityQuestion();
    question.setIngressNodeRegex(_srcNode.getName());
    question.setFinalNodeRegex(_dstNode.getName());
    question.setFailures(1);

    // Dont allow edges connected to _srcNode to fail
    question.setNotFailNode1Regex(".*");
    question.setNotFailNode2Regex(_srcNode.getName());

    final AnswerElement answer = _batfish.smtReachability(question);
    assertThat(answer, instanceOf(SmtReachabilityAnswerElement.class));

    final SmtReachabilityAnswerElement smtAnswer = (SmtReachabilityAnswerElement) answer;
    assertThat(smtAnswer, hasVerificationResult(hasIsVerified(true)));
  }
}