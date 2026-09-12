ProfitGuard — Business Recommendations
1. Prioritise late-delivery reduction

Late deliveries showed the clearest relationship with refunds.

Key findings:

Late-delivery refund rate was much higher than on-time delivery refund rate.
Statistical testing showed the difference was highly significant.
Delivery delay was also the strongest signal in the refund-prediction model.

Recommendation: prioritise operational actions that reduce delivery delays and flag delayed orders for proactive support.

2. Use refund-risk scoring as an early-warning system

The Logistic Regression model outperformed Random Forest for identifying refund risk.

Final model:

ROC-AUC: 0.700
Refund recall: ~51%
Refund precision: ~25%

Recommendation: use the model as a screening tool, not an automated decision system. High-risk orders can be reviewed or contacted before problems escalate.

3. Do not assume bigger discounts improve order value

The A/B-style analysis found:

Control average order value: £662.40
Higher-discount group: £647.15
Difference: about -2.3%
P-value: 0.235

The difference was not statistically significant.

Recommendation: avoid increasing discounts simply to drive basket value without a properly randomised experiment.

4. Investigate high-refund products and categories

The refund analysis identified products and categories contributing disproportionately to refund losses.

Recommendation: review:

product quality
product descriptions
packaging
supplier issues
fulfilment accuracy

for the highest-refund products first.

5. Focus marketing spend on acquisition efficiency

Marketing analysis showed meaningful differences in:

spend
acquired customers
CAC

Some channels acquired customers much more cheaply than others.

Recommendation: shift budget gradually toward lower-CAC channels, but do not judge channels by acquisition volume alone.

6. Treat delivery performance as a profit-protection metric

Delivery should not be tracked only as an operations KPI.

Because delays are associated with refunds, poor delivery performance can directly contribute to lost revenue.

Recommendation: include:

late-delivery rate
average delay
refund rate for late orders

in regular management reporting.

7. Monitor high-value products separately

A small number of products contribute disproportionately to revenue.

Recommendation: track top-revenue products separately for:

stock availability
refund rate
delivery performance
margin
supplier reliability

Problems in these products can have a larger financial impact.

Final project conclusion

ProfitGuard shows that the biggest actionable issue is not simply order value or discounting.

The strongest consistent signal across SQL, statistics, hypothesis testing, machine learning, and Power BI was:

Delivery delays are strongly associated with increased refund risk.

That becomes the central business story of the project.
