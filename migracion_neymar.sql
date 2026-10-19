alter table public.quimiqu_votes drop constraint if exists quimiqu_votes_player_check;
alter table public.quimiqu_votes add constraint quimiqu_votes_player_check check (player in ('messi','ronaldo','neymar'));
