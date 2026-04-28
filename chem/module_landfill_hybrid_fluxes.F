MODULE module_landfill_hybrid_fluxes
  USE module_configure
  USE module_state_description

  IMPLICIT NONE

CONTAINS

  SUBROUTINE add_landfill_hybrid_fluxes(ids, ide, jds, jde, kds, kde,          &
                                        ims, ime, jms, jme, kms, kme,          &
                                        its, ite, jts, jte, kts, kte,          &
                                        dtstep, dz8w, config_flags, rho_phy,   &
                                        chem, emis_ant, flqc, mavail)

    TYPE(grid_config_rec_type), INTENT(IN) :: config_flags
    INTEGER, INTENT(IN) :: ids, ide, jds, jde, kds, kde,                       &
                           ims, ime, jms, jme, kms, kme,                       &
                           its, ite, jts, jte, kts, kte
    REAL, INTENT(IN) :: dtstep
    REAL, DIMENSION(ims:ime, kms:kme, jms:jme, num_chem), INTENT(INOUT) :: chem
    REAL, DIMENSION(ims:ime, kms:kme, jms:jme), INTENT(IN) :: rho_phy, dz8w
    REAL, DIMENSION(ims:ime, kms:config_flags%kemit, jms:jme, num_emis_ant), INTENT(IN) :: emis_ant
    REAL, DIMENSION(ims:ime, jms:jme), INTENT(IN) :: flqc, mavail

    INTEGER :: i, j, k, n
    REAL :: conv_rho, flux_scale, mavail_floor
    INTEGER, DIMENSION(20), PARAMETER :: chem_idx = (/                           &
      p_ch4_s01, p_ch4_s02, p_ch4_s03, p_ch4_s04, p_ch4_s05,                     &
      p_ch4_s06, p_ch4_s07, p_ch4_s08, p_ch4_s09, p_ch4_s10,                     &
      p_ch4_s11, p_ch4_s12, p_ch4_s13, p_ch4_s14, p_ch4_s15,                     &
      p_ch4_s16, p_ch4_s17, p_ch4_s18, p_ch4_s19, p_ch4_s20 /)
    INTEGER, DIMENSION(20), PARAMETER :: emis_idx = (/                           &
      p_e_ch4_s01, p_e_ch4_s02, p_e_ch4_s03, p_e_ch4_s04, p_e_ch4_s05,           &
      p_e_ch4_s06, p_e_ch4_s07, p_e_ch4_s08, p_e_ch4_s09, p_e_ch4_s10,           &
      p_e_ch4_s11, p_e_ch4_s12, p_e_ch4_s13, p_e_ch4_s14, p_e_ch4_s15,           &
      p_e_ch4_s16, p_e_ch4_s17, p_e_ch4_s18, p_e_ch4_s19, p_e_ch4_s20 /)

    mavail_floor = 1.0e-12

    DO j = jts, jte
      DO i = its, ite
        DO k = kts, MIN(config_flags%kemit, kte)
          conv_rho = 8.0461e-6 / rho_phy(i, k, j) * dtstep / dz8w(i, k, j)

          IF (config_flags%landfill_flux_mode == 1) THEN
            flux_scale = flqc(i, j) / MAX(mavail(i, j), mavail_floor)
          ELSE
            flux_scale = 1.0
          END IF

          DO n = 1, 20
            chem(i, k, j, chem_idx(n)) = chem(i, k, j, chem_idx(n)) +            &
                                         flux_scale * conv_rho *                  &
                                         emis_ant(i, k, j, emis_idx(n))
          END DO
        END DO
      END DO
    END DO

  END SUBROUTINE add_landfill_hybrid_fluxes

END MODULE module_landfill_hybrid_fluxes
