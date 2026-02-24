;; ============================================================
;; Contract: trustforge.clar
;; Purpose : Non-transferable on-chain reputation engine
;; ============================================================

;; -------------------------
;; ERRORS
;; -------------------------
(define-constant ERR-NOT-AUTHORIZED      (err u15001))
(define-constant ERR-NOT-ISSUER          (err u15002))
(define-constant ERR-INVALID-AMOUNT      (err u15003))

;; -------------------------
;; CONSTANTS
;; -------------------------
(define-constant MAX-REPUTATION u10000)
(define-data-var contract-owner principal tx-sender)

;; -------------------------
;; STORAGE
;; -------------------------

;; Approved reputation issuers
(define-map issuers
  principal
  bool
)

;; Reputation scores
(define-map reputation
  principal
  {
    score: uint,
    updated-at: uint
  }
)

;; -------------------------
;; AUTHORIZATION
;; -------------------------

(define-read-only (is-owner?)
  (is-eq tx-sender (var-get contract-owner))
)

(define-read-only (is-issuer? (who principal))
  (default-to false (map-get? issuers who))
)

;; -------------------------
;; OWNER CONTROLS
;; -------------------------

(define-public (add-issuer (issuer principal))
  (begin
    (asserts! (is-owner?) ERR-NOT-AUTHORIZED)
    (map-set issuers issuer true)
    (ok true)
  )
)

(define-public (remove-issuer (issuer principal))
  (begin
    (asserts! (is-owner?) ERR-NOT-AUTHORIZED)
    (map-delete issuers issuer)
    (ok true)
  )
)

;; -------------------------
;; REPUTATION LOGIC
;; -------------------------

(define-public (adjust-reputation
  (user principal)
  (delta int)
)
  (begin
    (asserts! (is-issuer? tx-sender) ERR-NOT-ISSUER)

    (let (
      (current
        (default-to
          { score: u0, updated-at: u0 }
          (map-get? reputation user)
        )
      )

      (new-score
        (if (> delta 0)
            (+ (get score current) (to-uint delta))
            (if (> (get score current) (to-uint (- delta)))
                (- (get score current) (to-uint (- delta)))
                u0
            )
        )
      )
    )

      (asserts! (<= new-score MAX-REPUTATION) ERR-INVALID-AMOUNT)

      (map-set reputation
        user
        {
          score: new-score,
          updated-at: burn-block-height
        }
      )

      (ok new-score)
    )
  )
)

;; -------------------------
;; READ INTERFACE
;; -------------------------

(define-read-only (get-reputation (user principal))
  (default-to
    { score: u0, updated-at: u0 }
    (map-get? reputation user)
  )
)

(define-read-only (has-min-reputation?
  (user principal)
  (required uint)
)
  (>= (get score (get-reputation user)) required)
)
