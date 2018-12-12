match (t:transactions), (tip:transactionsInput), (top:transactionsOutput) detach delete t, tip, top


USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///tx.csv" AS line
CREATE (:transactions {numberInputs: line.n_ips, numberOutputs: line.n_ops, transactionId:line.tx_id, blockId:line.block_id});

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///txin.csv" AS line
CREATE (:transactionsInput {transactionId: line.tx_id, inputId: line.input_id, inputAddr:line.ip_addr_id, inputVal:line.ip_value});

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///txout.csv" AS line
CREATE (:transactionsOutput {transactionId: line.tx_id, outputId: line.output_id, outputAddr:line.op_addr_id, outputVal:line.op_value});

MATCH (t: transactions)
SET t.totalAmnt = 0

match (t:transactions), (tip:transactionsInput), (top:transactionsOutput)  where t.transactionId = tip.transactionId and t.transactionId = top.transactionId
merge(tip)-[r:IN{ipval:tip.inputVal}]-(t)-[r2:OUT{opval:top.outputVal}]-(top) 

match (t:transactions), (top:transactionsOutput) where t.transactionId = top.transactionId
set t.totalAmnt = t.totalAmnt + toInteger(r2.opval)



#######################################################################################
K-means
//Creating new clusters

CREATE (:Centroid {numberInputs: 0, numberOutputs: 1, totalAmnt: 0, index: 1, iteration: 1})
CREATE (:Centroid {numberInputs: 1, numberOutputs: 1, totalAmnt: 1000000, index: 2, iteration: 1})
CREATE (:Centroid {numberInputs: 1, numberOutputs: 2, totalAmnt: 5048765000, index: 3, iteration: 1})
CREATE (:Centroid {numberInputs: 2, numberOutputs: 2, totalAmnt: 9848055000, index: 4, iteration: 1})
CREATE (:Centroid {numberInputs: 15, numberOutputs: 2, totalAmnt: 8549464816, index: 5, iteration: 1})

*************************************

MATCH (s:transactions), (c1:Centroid{index: 1, iteration: 1}), (c2:Centroid{index: 2, iteration: 1}), (c3:Centroid{index: 3, iteration: 1}), (c4:Centroid{index: 4, iteration: 1}), (c5:Centroid{index: 5, iteration: 1})
SET s.distC1 = (toInteger(s.numberInputs) - c1.numberInputs)^2 + (toInteger(s.numberOutputs) - c1.numberOutputs)^2 + (s.totalAmnt - c1.totalAmnt)^2
SET s.distC2 = (toInteger(s.numberInputs) - c2.numberInputs)^2 + (toInteger(s.numberOutputs) - c2.numberOutputs)^2 + (s.totalAmnt - c2.totalAmnt)^2
SET s.distC3 = (toInteger(s.numberInputs) - c3.numberInputs)^2 + (toInteger(s.numberOutputs) - c3.numberOutputs)^2 + (s.totalAmnt - c3.totalAmnt)^2
SET s.distC4 = (toInteger(s.numberInputs) - c4.numberInputs)^2 + (toInteger(s.numberOutputs) - c4.numberOutputs)^2 + (s.totalAmnt - c4.totalAmnt)^2
SET s.distC5 = (toInteger(s.numberInputs) - c5.numberInputs)^2 + (toInteger(s.numberOutputs) - c5.numberOutputs)^2 + (s.totalAmnt - c5.totalAmnt)^2
WITH s, 
case 
when s.distC1 <= s.distC2 and s.distC1 <= s.distC3 and s.distC1 <= s.distC4 and s.distC1 <= s.distC5 then
c1
when s.distC2 <= s.distC1 and s.distC2 <= s.distC3 and s.distC2 <= s.distC4 and s.distC2 <= s.distC5 then
c2
when s.distC3 <= s.distC1 and s.distC3 <= s.distC2 and s.distC3 <= s.distC4 and s.distC3 <= s.distC5 then
c3
when s.distC4 <= s.distC1 and s.distC4 <= s.distC2 and s.distC4 <= s.distC3 and s.distC4 <= s.distC5 then
c4
else
c5
end as minC
CREATE (s)-[:IN_CLUSTER]->(minC)
RETURN *

*************************************

//Iteration-1
 
MATCH (s1:transactions)-[:IN_CLUSTER]->(c1:Centroid {index: 1, iteration: 1})
WITH avg(toInteger(s1.numberInputs)) as s1numberInputs, avg(toInteger(s1.numberOutputs)) as s1numberOutputs, avg(toInteger(s1.totalAmnt)) as s1totalAmnt

MATCH (s2:transactions)-[:IN_CLUSTER]->(c2:Centroid {index: 2, iteration: 1})
WITH s1numberInputs, s1numberOutputs, s1totalAmnt, avg(toInteger(s2.numberInputs)) as s2numberInputs, avg(toInteger(s2.numberOutputs)) as s2numberOutputs, avg(toInteger(s2.totalAmnt)) as s2totalAmnt

MATCH (s3:transactions)-[:IN_CLUSTER]->(c3:Centroid {index: 3, iteration: 1})
WITH s1numberInputs, s1numberOutputs, s1totalAmnt, s2numberInputs, s2numberOutputs, s2totalAmnt, avg(toInteger(s3.numberInputs)) as s3numberInputs, avg(toInteger(s3.numberOutputs)) as s3numberOutputs, avg(toInteger(s3.totalAmnt)) as s3totalAmnt

MATCH (s4:transactions)-[:IN_CLUSTER]->(c4:Centroid {index: 4, iteration: 1})
WITH s1numberInputs, s1numberOutputs, s1totalAmnt, s2numberInputs, s2numberOutputs, s2totalAmnt, s3numberInputs, s3numberOutputs, s3totalAmnt, avg(toInteger(s4.numberInputs)) as s4numberInputs, avg(toInteger(s4.numberOutputs)) as s4numberOutputs, avg(toInteger(s4.totalAmnt)) as s4totalAmnt

MATCH (s5:transactions)-[:IN_CLUSTER]->(c5:Centroid {index: 5, iteration: 1})
WITH s1numberInputs, s1numberOutputs, s1totalAmnt, s2numberInputs, s2numberOutputs, s2totalAmnt, s3numberInputs, s3numberOutputs, s3totalAmnt, s4numberInputs, s4numberOutputs, s4totalAmnt, avg(toInteger(s5.numberInputs)) as s5numberInputs, avg(toInteger(s5.numberOutputs)) as s5numberOutputs, avg(toInteger(s5.totalAmnt)) as s5totalAmnt


CREATE (:Centroid {numberInputs: s1numberInputs, numberOutputs: s1numberOutputs, totalAmnt: s1totalAmnt, index: 1, iteration: 2})
CREATE (:Centroid {numberInputs: s2numberInputs, numberOutputs: s2numberOutputs, totalAmnt: s2totalAmnt, index: 2, iteration: 2})
CREATE (:Centroid {numberInputs: s3numberInputs, numberOutputs: s3numberOutputs, totalAmnt: s3totalAmnt, index: 3, iteration: 2})
CREATE (:Centroid {numberInputs: s4numberInputs, numberOutputs: s4numberOutputs, totalAmnt: s4totalAmnt, index: 4, iteration: 2})
CREATE (:Centroid {numberInputs: s5numberInputs, numberOutputs: s5numberOutputs, totalAmnt: s5totalAmnt, index: 5, iteration: 2})

RETURN *


//next cluster assignment, identical to the first, except that interation equals 2 in match clause
MATCH (s:transactions), (c1:Centroid{index: 1, iteration: 2}), (c2:Centroid{index: 2, iteration: 2}), (c3:Centroid{index: 3, iteration: 2}), (c4:Centroid{index: 4, iteration: 2}), (c5:Centroid{index: 5, iteration: 2}) 
SET s.distC1 = (toInteger(s.numberInputs) - c1.numberInputs)^2 + (toInteger(s.numberOutputs) - c1.numberOutputs)^2 + (s.totalAmnt - c1.totalAmnt)^2
SET s.distC2 = (toInteger(s.numberInputs) - c2.numberInputs)^2 + (toInteger(s.numberOutputs) - c2.numberOutputs)^2 + (s.totalAmnt - c2.totalAmnt)^2
SET s.distC3 = (toInteger(s.numberInputs) - c3.numberInputs)^2 + (toInteger(s.numberOutputs) - c3.numberOutputs)^2 + (s.totalAmnt - c3.totalAmnt)^2
SET s.distC4 = (toInteger(s.numberInputs) - c4.numberInputs)^2 + (toInteger(s.numberOutputs) - c4.numberOutputs)^2 + (s.totalAmnt - c4.totalAmnt)^2
SET s.distC5 = (toInteger(s.numberInputs) - c5.numberInputs)^2 + (toInteger(s.numberOutputs) - c5.numberOutputs)^2 + (s.totalAmnt - c5.totalAmnt)^2
WITH s, 
case 
when s.distC1 <= s.distC2 and s.distC1 <= s.distC3 and s.distC1 <= s.distC4 and s.distC1 <= s.distC5 then
c1
when s.distC2 <= s.distC1 and s.distC2 <= s.distC3 and s.distC2 <= s.distC4 and s.distC2 <= s.distC5 then
c2
when s.distC3 <= s.distC1 and s.distC3 <= s.distC2 and s.distC3 <= s.distC4 and s.distC3 <= s.distC5 then
c3
when s.distC4 <= s.distC1 and s.distC4 <= s.distC2 and s.distC4 <= s.distC3 and s.distC4 <= s.distC5 then
c4
else
c5
end as minC2
CREATE (s)-[:IN_CLUSTER]->(minC2)
RETURN *

*******************************************************
//Iteration-2
 
MATCH (s_1:transactions)-[:IN_CLUSTER]->(c1:Centroid {index: 1, iteration: 2})
WITH avg(toInteger(s_1.numberInputs)) as s_1numberInputs, avg(toInteger(s_1.numberOutputs)) as s_1numberOutputs, avg(toInteger(s_1.totalAmnt)) as s_1totalAmnt

MATCH (s_2:transactions)-[:IN_CLUSTER]->(c2:Centroid {index: 2, iteration: 2})
WITH s_1numberInputs, s_1numberOutputs, s_1totalAmnt, avg(toInteger(s_2.numberInputs)) as s_2numberInputs, avg(toInteger(s_2.numberOutputs)) as s_2numberOutputs, avg(toInteger(s_2.totalAmnt)) as s_2totalAmnt

MATCH (s_3:transactions)-[:IN_CLUSTER]->(c3:Centroid {index: 3, iteration: 2})
WITH s_1numberInputs, s_1numberOutputs, s_1totalAmnt, s_2numberInputs, s_2numberOutputs, s_2totalAmnt, avg(toInteger(s_3.numberInputs)) as s_3numberInputs, avg(toInteger(s_3.numberOutputs)) as s_3numberOutputs, avg(toInteger(s_3.totalAmnt)) as s_3totalAmnt

MATCH (s_4:transactions)-[:IN_CLUSTER]->(c4:Centroid {index: 4, iteration: 2})
WITH s_1numberInputs, s_1numberOutputs, s_1totalAmnt, s_2numberInputs, s_2numberOutputs, s_2totalAmnt, s_3numberInputs, s_3numberOutputs, s_3totalAmnt, avg(toInteger(s_4.numberInputs)) as s_4numberInputs, avg(toInteger(s_4.numberOutputs)) as s_4numberOutputs, avg(toInteger(s_4.totalAmnt)) as s_4totalAmnt

MATCH (s_5:transactions)-[:IN_CLUSTER]->(c5:Centroid {index: 5, iteration: 2})
WITH s_1numberInputs, s_1numberOutputs, s_1totalAmnt, s_2numberInputs, s_2numberOutputs, s_2totalAmnt, s_3numberInputs, s_3numberOutputs, s_3totalAmnt, s_4numberInputs, s_4numberOutputs, s_4totalAmnt, avg(toInteger(s_5.numberInputs)) as s_5numberInputs, avg(toInteger(s_5.numberOutputs)) as s_5numberOutputs, avg(toInteger(s_5.totalAmnt)) as s_5totalAmnt


CREATE (:Centroid {numberInputs: s_1numberInputs, numberOutputs: s_1numberOutputs, totalAmnt: s_1totalAmnt, index: 1, iteration: 3})
CREATE (:Centroid {numberInputs: s_2numberInputs, numberOutputs: s_2numberOutputs, totalAmnt: s_2totalAmnt, index: 2, iteration: 3})
CREATE (:Centroid {numberInputs: s_3numberInputs, numberOutputs: s_3numberOutputs, totalAmnt: s_3totalAmnt, index: 3, iteration: 3})
CREATE (:Centroid {numberInputs: s_4numberInputs, numberOutputs: s_4numberOutputs, totalAmnt: s_4totalAmnt, index: 4, iteration: 3})
CREATE (:Centroid {numberInputs: s_5numberInputs, numberOutputs: s_5numberOutputs, totalAmnt: s_5totalAmnt, index: 5, iteration: 3})

RETURN *

//next cluster assignment, identical to the first, except that interation equals 2 in match clause
MATCH (s:transactions), (c1:Centroid{index: 1, iteration: 3}), (c2:Centroid{index: 2, iteration: 3}), (c3:Centroid{index: 3, iteration: 3}), (c4:Centroid{index: 4, iteration: 3}), (c5:Centroid{index: 5, iteration: 3}) 
SET s.distC1 = (toInteger(s.numberInputs) - c1.numberInputs)^2 + (toInteger(s.numberOutputs) - c1.numberOutputs)^2 + (s.totalAmnt - c1.totalAmnt)^2
SET s.distC2 = (toInteger(s.numberInputs) - c2.numberInputs)^2 + (toInteger(s.numberOutputs) - c2.numberOutputs)^2 + (s.totalAmnt - c2.totalAmnt)^2
SET s.distC3 = (toInteger(s.numberInputs) - c2.numberInputs)^2 + (toInteger(s.numberOutputs) - c3.numberOutputs)^2 + (s.totalAmnt - c3.totalAmnt)^2
SET s.distC4 = (toInteger(s.numberInputs) - c4.numberInputs)^2 + (toInteger(s.numberOutputs) - c4.numberOutputs)^2 + (s.totalAmnt - c4.totalAmnt)^2
SET s.distC5 = (toInteger(s.numberInputs) - c5.numberInputs)^2 + (toInteger(s.numberOutputs) - c5.numberOutputs)^2 + (s.totalAmnt - c5.totalAmnt)^2

WITH s, 
case 
when s.distC1 <= s.distC2 and s.distC1 <= s.distC3 and s.distC1 <= s.distC4 and s.distC1 <= s.distC5 then
c1
when s.distC2 <= s.distC1 and s.distC2 <= s.distC3 and s.distC2 <= s.distC4 and s.distC2 <= s.distC5 then
c2
when s.distC3 <= s.distC1 and s.distC3 <= s.distC2 and s.distC3 <= s.distC4 and s.distC3 <= s.distC5 then
c3
when s.distC4 <= s.distC1 and s.distC4 <= s.distC2 and s.distC4 <= s.distC3 and s.distC4 <= s.distC5 then
c4
else
c5
end as minC3
CREATE (s)-[:IN_CLUSTER]->(minC3)
RETURN *

**********************************************************************************************************
iteration - 3
MATCH (s__1:transactions)-[:IN_CLUSTER]->(c1:Centroid {index: 1, iteration: 3})
WITH avg(toInteger(s__1.numberInputs)) as s__1numberInputs, avg(toInteger(s__1.numberOutputs)) as s__1numberOutputs, avg(toInteger(s__1.totalAmnt)) as s__1totalAmnt

MATCH (s__2:transactions)-[:IN_CLUSTER]->(c2:Centroid {index: 2, iteration: 3})
WITH avg(toInteger(s__2.numberInputs)) as s__2numberInputs, avg(toInteger(s__2.numberOutputs)) as s__2numberOutputs, avg(toInteger(s__2.totalAmnt)) as s__2totalAmnt

MATCH (s__3:transactions)-[:IN_CLUSTER]->(c3:Centroid {index: 3, iteration: 3})
WITH avg(toInteger(s__3.numberInputs)) as s__3numberInputs, avg(toInteger(s__3.numberOutputs)) as s__3numberOutputs, avg(toInteger(s__3.totalAmnt)) as s__3totalAmnt

MATCH (s__4:transactions)-[:IN_CLUSTER]->(c4:Centroid {index: 4, iteration: 3})
WITH avg(toInteger(s__4.numberInputs)) as s__4numberInputs, avg(toInteger(s__4.numberOutputs)) as s__4numberOutputs, avg(toInteger(s__4.totalAmnt)) as s__4totalAmnt

MATCH (s__5:transactions)-[:IN_CLUSTER]->(c5:Centroid {index: 5, iteration: 3})
WITH avg(toInteger(s__5.numberInputs)) as s__5numberInputs, avg(toInteger(s__5.numberOutputs)) as s__5numberOutputs, avg(toInteger(s__5.totalAmnt)) as s__5totalAmnt


CREATE (:Centroid {numberInputs: s__1numberInputs, numberOutputs: s__1numberOutputs, totalAmnt: s__1totalAmnt, index: 1, iteration: 4})
CREATE (:Centroid {numberInputs: s__2numberInputs, numberOutputs: s__2numberOutputs, totalAmnt: s__2totalAmnt, index: 2, iteration: 4})
CREATE (:Centroid {numberInputs: s__3numberInputs, numberOutputs: s__3numberOutputs, totalAmnt: s__3totalAmnt, index: 3, iteration: 4})
CREATE (:Centroid {numberInputs: s__4numberInputs, numberOutputs: s__4numberOutputs, totalAmnt: s__4totalAmnt, index: 4, iteration: 4})
CREATE (:Centroid {numberInputs: s__5numberInputs, numberOutputs: s__5numberOutputs, totalAmnt: s__5totalAmnt, index: 5, iteration: 4})

RETURN *

//next cluster assignment, identical to the first, except that interation equals 2 in match clause
MATCH (s:transactions), (c1:Centroid{index: 1, iteration: 3}), (c2:Centroid{index: 2, iteration: 3}), (c3:Centroid{index: 3, iteration: 3}), (c4:Centroid{index: 4, iteration: 3}), (c5:Centroid{index: 5, iteration: 3}) 
SET s.distC1 = (toInteger(s.numberInputs) - c1.numberInputs)^2 + (toInteger(s.numberOutputs) - c1.numberOutputs)^2 + (s.totalAmnt - c1.totalAmnt)^2
SET s.distC2 = (toInteger(s.numberInputs) - c2.numberInputs)^2 + (toInteger(s.numberOutputs) - c2.numberOutputs)^2 + (s.totalAmnt - c2.totalAmnt)^2
SET s.distC3 = (toInteger(s.numberInputs) - c2.numberInputs)^2 + (toInteger(s.numberOutputs) - c3.numberOutputs)^2 + (s.totalAmnt - c3.totalAmnt)^2
SET s.distC4 = (toInteger(s.numberInputs) - c4.numberInputs)^2 + (toInteger(s.numberOutputs) - c4.numberOutputs)^2 + (s.totalAmnt - c4.totalAmnt)^2
SET s.distC5 = (toInteger(s.numberInputs) - c5.numberInputs)^2 + (toInteger(s.numberOutputs) - c5.numberOutputs)^2 + (s.totalAmnt - c5.totalAmnt)^2

WITH s, 
case 
when s.distC1 <= s.distC2 and s.distC1 <= s.distC3 and s.distC1 <= s.distC4 and s.distC1 <= s.distC5 then
c1
when s.distC2 <= s.distC1 and s.distC2 <= s.distC3 and s.distC2 <= s.distC4 and s.distC2 <= s.distC5 then
c2
when s.distC3 <= s.distC1 and s.distC3 <= s.distC2 and s.distC3 <= s.distC4 and s.distC3 <= s.distC5 then
c3
when s.distC4 <= s.distC1 and s.distC4 <= s.distC2 and s.distC4 <= s.distC3 and s.distC4 <= s.distC5 then
c4
else
c5
end as minC4
CREATE (s)-[:IN_CLUSTER]->(minC4)
RETURN *

**********************************************************************************************************
iteration - 4

MATCH (s___1:transactions)-[:IN_CLUSTER]->(c1:Centroid {index: 1, iteration: 4})
WITH avg(toInteger(s___1.numberInputs)) as s___1numberInputs, avg(toInteger(s___1.numberOutputs)) as s___1numberOutputs, avg(toInteger(s___1.totalAmnt)) as s___1totalAmnt

MATCH (s___2:transactions)-[:IN_CLUSTER]->(c2:Centroid {index: 2, iteration: 4})
WITH avg(toInteger(s___2.numberInputs)) as s___2numberInputs, avg(toInteger(s___2.numberOutputs)) as s___2numberOutputs, avg(toInteger(s___2.totalAmnt)) as s___2totalAmnt

MATCH (s___3:transactions)-[:IN_CLUSTER]->(c3:Centroid {index: 3, iteration: 4})
WITH avg(toInteger(s___3.numberInputs)) as s___3numberInputs, avg(toInteger(s___3.numberOutputs)) as s___3numberOutputs, avg(toInteger(s___3.totalAmnt)) as s___3totalAmnt

MATCH (s___4:transactions)-[:IN_CLUSTER]->(c4:Centroid {index: 4, iteration: 4})
WITH avg(toInteger(s___4.numberInputs)) as s___4numberInputs, avg(toInteger(s___4.numberOutputs)) as s___4numberOutputs, avg(toInteger(s___4.totalAmnt)) as s___4totalAmnt

MATCH (s___5:transactions)-[:IN_CLUSTER]->(c5:Centroid {index: 5, iteration: 4})
WITH avg(toInteger(s___5.numberInputs)) as s___5numberInputs, avg(toInteger(s___5.numberOutputs)) as s___5numberOutputs, avg(toInteger(s___5.totalAmnt)) as s___5totalAmnt


CREATE (:Centroid {numberInputs: s___1numberInputs, numberOutputs: s___1numberOutputs, totalAmnt: s___1totalAmnt, index: 1, iteration: 5})
CREATE (:Centroid {numberInputs: s___2numberInputs, numberOutputs: s___2numberOutputs, totalAmnt: s___2totalAmnt, index: 2, iteration: 5})
CREATE (:Centroid {numberInputs: s___3numberInputs, numberOutputs: s___3numberOutputs, totalAmnt: s___3totalAmnt, index: 3, iteration: 5})
CREATE (:Centroid {numberInputs: s___4numberInputs, numberOutputs: s___4numberOutputs, totalAmnt: s___4totalAmnt, index: 4, iteration: 5})
CREATE (:Centroid {numberInputs: s___5numberInputs, numberOutputs: s___5numberOutputs, totalAmnt: s___5totalAmnt, index: 5, iteration: 5})

RETURN *

//next cluster assignment, identical to the first, except that interation equals 2 in match clause
MATCH (s:transactions), (c1:Centroid{index: 1, iteration: 3}), (c2:Centroid{index: 2, iteration: 3}), (c3:Centroid{index: 3, iteration: 3}), (c4:Centroid{index: 4, iteration: 3}), (c5:Centroid{index: 5, iteration: 3}) 
SET s.distC1 = (toInteger(s.numberInputs) - c1.numberInputs)^2 + (toInteger(s.numberOutputs) - c1.numberOutputs)^2 + (s.totalAmnt - c1.totalAmnt)^2
SET s.distC2 = (toInteger(s.numberInputs) - c2.numberInputs)^2 + (toInteger(s.numberOutputs) - c2.numberOutputs)^2 + (s.totalAmnt - c2.totalAmnt)^2
SET s.distC3 = (toInteger(s.numberInputs) - c2.numberInputs)^2 + (toInteger(s.numberOutputs) - c3.numberOutputs)^2 + (s.totalAmnt - c3.totalAmnt)^2
SET s.distC4 = (toInteger(s.numberInputs) - c4.numberInputs)^2 + (toInteger(s.numberOutputs) - c4.numberOutputs)^2 + (s.totalAmnt - c4.totalAmnt)^2
SET s.distC5 = (toInteger(s.numberInputs) - c5.numberInputs)^2 + (toInteger(s.numberOutputs) - c5.numberOutputs)^2 + (s.totalAmnt - c5.totalAmnt)^2

WITH s, 
case 
when s.distC1 <= s.distC2 and s.distC1 <= s.distC3 and s.distC1 <= s.distC4 and s.distC1 <= s.distC5 then
c1
when s.distC2 <= s.distC1 and s.distC2 <= s.distC3 and s.distC2 <= s.distC4 and s.distC2 <= s.distC5 then
c2
when s.distC3 <= s.distC1 and s.distC3 <= s.distC2 and s.distC3 <= s.distC4 and s.distC3 <= s.distC5 then
c3
when s.distC4 <= s.distC1 and s.distC4 <= s.distC2 and s.distC4 <= s.distC3 and s.distC4 <= s.distC5 then
c4
else
c5
end as minC5
CREATE (s)-[:IN_CLUSTER]->(minC5)
RETURN *


