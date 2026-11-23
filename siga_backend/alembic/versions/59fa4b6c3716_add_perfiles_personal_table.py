"""add_perfiles_personal_table

Revision ID: 59fa4b6c3716
Revises: b1c2d3e4f5a6
Create Date: 2026-01-01 00:00:00.000000
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '59fa4b6c3716'
down_revision: Union[str, None] = 'b1c2d3e4f5a6'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        'perfiles_personal',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('user_id', sa.Integer(), nullable=False),
        sa.Column('condicion_laboral', sa.String(length=50), nullable=False),
        sa.Column('numero_resolucion', sa.String(length=100), nullable=True),
        sa.Column('fecha_fin_contrato', sa.DateTime(), nullable=True),
        sa.Column('cargo_funcional', sa.String(length=50), nullable=False),
        sa.Column('profesion_titulo', sa.String(length=200), nullable=True),
        sa.Column('programa_estudio_id', sa.Integer(), nullable=True),
        sa.ForeignKeyConstraint(['user_id'], ['core_users.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('user_id'),
    )
    op.create_index(op.f('ix_perfiles_personal_id'), 'perfiles_personal', ['id'], unique=False)
    op.create_index(op.f('ix_perfiles_personal_user_id'), 'perfiles_personal', ['user_id'], unique=False)


def downgrade() -> None:
    op.drop_index(op.f('ix_perfiles_personal_user_id'), table_name='perfiles_personal')
    op.drop_index(op.f('ix_perfiles_personal_id'), table_name='perfiles_personal')
    op.drop_table('perfiles_personal')