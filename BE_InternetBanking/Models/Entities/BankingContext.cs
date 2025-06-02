using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace BE_InternetBanking.Models.Entities;

public partial class BankingContext : DbContext
{
    public BankingContext()
    {
    }

    public BankingContext(DbContextOptions<BankingContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Account> Accounts { get; set; }

    public virtual DbSet<DailyAccountSeq> DailyAccountSeqs { get; set; }

    public virtual DbSet<LoginSession> LoginSessions { get; set; }

    public virtual DbSet<Message> Messages { get; set; }

    public virtual DbSet<OtpRequest> OtpRequests { get; set; }

    public virtual DbSet<Role> Roles { get; set; }

    public virtual DbSet<TransactionBanking> TransactionBankings { get; set; }

    public virtual DbSet<User> Users { get; set; }

    public virtual DbSet<UserRole> UserRoles { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        => optionsBuilder.UseSqlServer("Name=Connection");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Account>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Accounts__3214EC0723754979");

            entity.HasIndex(e => e.AccountNumber, "UQ__Accounts__BE2ACD6FEB857735").IsUnique();

            entity.Property(e => e.Id).HasDefaultValueSql("(newid())");
            entity.Property(e => e.AccountNumber)
                .HasMaxLength(20)
                .IsUnicode(false);
            entity.Property(e => e.Balance)
                .HasDefaultValue(0m)
                .HasColumnType("decimal(18, 2)");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.Status)
                .HasMaxLength(20)
                .IsUnicode(false)
                .HasDefaultValue("ACTIVE");

            entity.HasOne(d => d.User).WithMany(p => p.Accounts)
                .HasForeignKey(d => d.UserId)
                .HasConstraintName("FK__Accounts__UserId__412EB0B6");
        });

        modelBuilder.Entity<DailyAccountSeq>(entity =>
        {
            entity.HasKey(e => e.DateToday).HasName("PK__DailyAcc__C53D9495BE96998A");

            entity.ToTable("DailyAccountSeq");
        });

        modelBuilder.Entity<LoginSession>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__LoginSes__3214EC07C47C32BA");

            entity.Property(e => e.Id).HasDefaultValueSql("(newid())");
            entity.Property(e => e.DeviceInfo).HasMaxLength(255);
            entity.Property(e => e.FcmToken).HasMaxLength(255);
            entity.Property(e => e.IsActive).HasDefaultValue(true);
            entity.Property(e => e.LoginAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.LogoutAt).HasColumnType("datetime");

            entity.HasOne(d => d.User).WithMany(p => p.LoginSessions)
                .HasForeignKey(d => d.UserId)
                .HasConstraintName("FK__LoginSess__UserI__5441852A");
        });

        modelBuilder.Entity<Message>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Messages__3214EC07EA114FD0");

            entity.Property(e => e.Id).HasDefaultValueSql("(newid())");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");

            entity.HasOne(d => d.Account).WithMany(p => p.Messages)
                .HasForeignKey(d => d.AccountId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Messages_Accounts");
        });

        modelBuilder.Entity<OtpRequest>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__OtpReque__3214EC0794D569FB");

            entity.Property(e => e.Id).HasDefaultValueSql("(newid())");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.ExpiredAt).HasColumnType("datetime");
            entity.Property(e => e.IsUsed).HasDefaultValue(false);
            entity.Property(e => e.OtpCode)
                .HasMaxLength(10)
                .IsUnicode(false);
            entity.Property(e => e.SentVia)
                .HasMaxLength(10)
                .IsUnicode(false);

            entity.HasOne(d => d.User).WithMany(p => p.OtpRequests)
                .HasForeignKey(d => d.UserId)
                .HasConstraintName("FK__OtpReques__UserI__4E88ABD4");
        });

        modelBuilder.Entity<Role>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Roles__3214EC072A4EC05E");

            entity.HasIndex(e => e.Name, "UQ__Roles__737584F6865FA4D1").IsUnique();

            entity.Property(e => e.Id).HasDefaultValueSql("(newid())");
            entity.Property(e => e.Description).HasMaxLength(255);
            entity.Property(e => e.Name)
                .HasMaxLength(50)
                .IsUnicode(false);
        });

        modelBuilder.Entity<TransactionBanking>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Transact__3214EC07E3E0C429");

            entity.ToTable("TransactionBanking");

            entity.Property(e => e.Id).HasDefaultValueSql("(newid())");
            entity.Property(e => e.Amount).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.Message).HasMaxLength(255);
            entity.Property(e => e.Status)
                .HasMaxLength(20)
                .IsUnicode(false)
                .HasDefaultValue("SUCCESS");
            entity.Property(e => e.Timestamp)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");

            entity.HasOne(d => d.FromAccount).WithMany(p => p.TransactionBankingFromAccounts)
                .HasForeignKey(d => d.FromAccountId)
                .HasConstraintName("FK__Transacti__FromA__47DBAE45");

            entity.HasOne(d => d.ToAccount).WithMany(p => p.TransactionBankingToAccounts)
                .HasForeignKey(d => d.ToAccountId)
                .HasConstraintName("FK__Transacti__ToAcc__48CFD27E");
        });

        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Users__3214EC07D5E047E8");

            entity.HasIndex(e => e.PhoneNumber, "UQ__Users__85FB4E38FA499A63").IsUnique();

            entity.HasIndex(e => e.Email, "UQ__Users__A9D10534B479FB94").IsUnique();

            entity.Property(e => e.Id).HasDefaultValueSql("(newid())");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.Email).HasMaxLength(100);
            entity.Property(e => e.FullName).HasMaxLength(100);
            entity.Property(e => e.IsEmailVerified).HasDefaultValue(false);
            entity.Property(e => e.IsPhoneVerified).HasDefaultValue(false);
            entity.Property(e => e.PasswordHash).HasMaxLength(255);
            entity.Property(e => e.PhoneNumber).HasMaxLength(15);
        });

        modelBuilder.Entity<UserRole>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__UserRole__3214EC0727C80B34");

            entity.Property(e => e.Id).HasDefaultValueSql("(newid())");
            entity.Property(e => e.AssignedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");

            entity.HasOne(d => d.Role).WithMany(p => p.UserRoles)
                .HasForeignKey(d => d.RoleId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_UserRoles_Roles");

            entity.HasOne(d => d.User).WithMany(p => p.UserRoles)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_UserRoles_Users");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
