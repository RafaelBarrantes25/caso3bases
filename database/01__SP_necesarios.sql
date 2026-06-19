CREATE PROCEDURE sp_ObtenerProposiciones
    @offset INT
AS
BEGIN
    select p.id, p.title, description, pb.username createdBy, pt.username targetUser, smp.postUrl as externalLink,
	p.challengeStartsAt challengeStart, p.challengeEndsAt challengeEnd, p.votingStartsAt votingStart, p.votingClosesAt votingEnd,
	case 
		when pr.id IS NOT NULL THEN 'completed'
		when p.rejectedAt IS NOT NULL THEN 'canceled'
		when GETDATE() between p.challengeStartsAt and p.challengeEndsAt THEN 'challenge'
		when GETDATE() between p.votingStartsAt and p.votingClosesAt THEN 'voting'
		else 'closed'
	end status
	from propositions p
	left join users pb on p.proposedBy = pb.id
	left join users pt on p.proposedTo = pt.id
	left join propositionSourcePosts psp on p.id = psp.propositionId
	left join socialMediaPosts smp on psp.socialMediaPostId = smp.id
	left join propositionResults pr on pr.propositionId = p.id
	order by p.id desc
	OFFSET 30*(@offset-1) ROWS
	FETCH NEXT 30 ROWS ONLY;
END
GO

CREATE PROCEDURE sp_ObtenerProposicionesAbiertas
    @offset INT
AS
BEGIN
    select * from
	(select p.id, p.title, description, pb.username createdBy, pt.username targetUser, smp.postUrl as externalLink,
	p.challengeStartsAt challengeStart, p.challengeEndsAt challengeEnd, p.votingStartsAt votingStart, p.votingClosesAt votingEnd,
	case 
		when pr.id IS NOT NULL THEN 'completed'
		when p.rejectedAt IS NOT NULL THEN 'canceled'
		when GETDATE() between p.challengeStartsAt and p.challengeEndsAt THEN 'challenge'
		when GETDATE() between p.votingStartsAt and p.votingClosesAt THEN 'voting'
		else 'closed'
	end status
	from propositions p
	left join users pb on p.proposedBy = pb.id
	left join users pt on p.proposedTo = pt.id
	left join propositionSourcePosts psp on p.id = psp.propositionId
	left join socialMediaPosts smp on psp.socialMediaPostId = smp.id
	left join propositionResults pr on pr.propositionId = p.id) datos
	where datos.status != 'closed' and datos.status != 'completed'
	order by datos.id desc
	OFFSET 30*(@offset-1) ROWS
	FETCH NEXT 30 ROWS ONLY;
END
GO

CREATE PROCEDURE sp_ValidarPass
    @email VARCHAR(100),
    @pass VARCHAR(100)
AS
BEGIN
	select case 
		when u.password = CONVERT(VARBINARY(256), HASHBYTES('SHA2_256', @pass)) THEN u.id
		else -1
		end valido 
	from users u 
	where u.email = @email;
END
GO

CREATE PROCEDURE sp_ObtenerUsuario
    @id int
AS
BEGIN
	select u.id id, CONCAT(u.name, ' ',u.lastName) name, u.username username, u.email email, calc.balance moneyBalance, w.balance pointsBalance
	from users u
	left join (select uu.id id, ---CONCAT(u.name, ' ',u.lastName) name, u.username username, u.email email,
		SUM(w.balance * COALESCE(er.rate, 1)) balance from users uu
		left join wallets w on uu.id = w.userId
		left join currencies c on w.currencyId = c.id
		left join exchangeRates er on er.fromCurrencyId = c.id and er.toCurrencyId = 1
		where c.currencyTypeId = 1
		group by uu.id  
		) calc on calc.id = u.id
	left join wallets w on u.id = w.userId
	left join currencies c on w.currencyId = c.id
	where u.id = @id and c.currencyTypeId = 2
END
GO

CREATE PROCEDURE sp_ObtenerProposicionesPropias
    @id int
AS
BEGIN
	select p.id, p.title, description, pb.username createdBy, pt.username targetUser, smp.postUrl as externalLink,
	p.challengeStartsAt challengeStart, p.challengeEndsAt challengeEnd, p.votingStartsAt votingStart, p.votingClosesAt votingEnd,
	case 
		when pr.id IS NOT NULL THEN 'completed'
		when p.rejectedAt IS NOT NULL THEN 'canceled'
		when GETDATE() between p.challengeStartsAt and p.challengeEndsAt THEN 'challenge'
		when GETDATE() between p.votingStartsAt and p.votingClosesAt THEN 'voting'
		else 'closed'
	end status
	from propositions p
	left join users pb on p.proposedBy = pb.id
	left join users pt on p.proposedTo = pt.id
	left join propositionSourcePosts psp on p.id = psp.propositionId
	left join socialMediaPosts smp on psp.socialMediaPostId = smp.id
	left join propositionResults pr on pr.propositionId = p.id
	where p.proposedBy = @id
	order by p.id desc
END
GO

CREATE PROCEDURE sp_UsernameExiste
    @user VARCHAR(100)
AS
BEGIN
	select u.id from users u where u.username = @user;
END
GO

CREATE PROCEDURE sp_CrearProposicion
	@title varchar(130),
	@description varchar(130),
	@votingStart varchar(40),
	@votingEnd varchar(40),
	@challengeStart varchar(40),
	@challengeEnd varchar(40),
	@externalLink varchar(130),
	@createdBy int,
	@targetUser int
AS
BEGIN
	insert into propositions (title, description, proposedBy, proposedTo, propositionStatusId, votingStartsAt, votingClosesAt,
	challengeStartsAt, challengeEndsAt, enabled, createdAt, checksum)
	VALUES (@title, @description, @createdBy, @targetUser, 1,
	CONVERT(DATE, CONCAT(@votingStart,':00.000'), 126), CONVERT(DATE, CONCAT(@votingEnd,':00.000'), 126),
	CONVERT(DATE, CONCAT(@challengeStart,':00.000'), 126), CONVERT(DATE, CONCAT(@challengeEnd,':00.000'), 126), 1, GETDATE(), CONVERT(VARBINARY(32), HASHBYTES('SHA2_256', 'GATHEL_BASE_SEED')))

END
GO

