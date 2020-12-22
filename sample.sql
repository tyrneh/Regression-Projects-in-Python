/*
very simple query where I pretend to join a table containing a monthly view of credit-card accounts, to a transaction-level table
that contains every transaction of every account. I attempt to find the monthly sum of payments from the transaction level table and attach it to the monthly view of accounts.
Apologies if there's any mistakes as I haven't used SQL in quite a few months and I'm just visualizing what the tables would look like.
*/

create or replace table sb.user_xyz.analysis as (
select
    a.acct_id
    ,a.stmt_bgn_dt
    ,a.stmt_end_dt
    ,sum(b.trxn_amt) as payment
   
    from
    (select * from db.table_per_account_per_credit_card_statement --every account will have a new row every month
     where country = 'Canada'
     and status = 'active') as a
     
    left join
    (select * from db.transaction_level_table  -- each transaction is recorded as a new row
     where country = 'Canada'
     and status = 'active'
     and trxn_type = 'payment'                 --I only want the transactions that are payments
     ) as b
     on a.acct_id = b.acct_id                  --join by matching accounts
     and b.trxn_dt >= a.stmt_bgn_dt            --make sure that the transactions happend after the start of the statement
     and b.trxn_dt <= a.stmt_end_dt            --make sure the transaction happened prior to the end of the statement
    
    group by 1,2,3
    
    --the left join will result in every transaction being a new row
    --But then by grouping by account per statement, and summing trxn_amt over all rows, that leaves 1 row of sum(trxn_amt) per statement
);

